#!/usr/bin/env ruby

#=begin
#ruby-aes (optimized version)
#Written by Alex Boussinet <dbug@wanadoo.fr>
#
#API: new( key_length, mode, key, iv )
#     init_aes( key_length, mode, key, iv )
#     cipher_encrypt( block )
#     cipher_decrypt( block )
#
#This version is adapted from the Rijndael Specifications (dfips-AES.pdf)
#Now using constant arrays for performance.(suggested by Jabari Zakiya)
#=end

require 'aes_cons'

class AesAlg
  include AesCons

  def mixColumns
    t = ""
    (0..3).each { |j| i = j*4
      b0 = @state[i]; b1 = @state[i+1]; b2 = @state[i+2]; b3 = @state[i+3]
      t << (G2X[b0] ^ G3X[b1] ^ b2 ^ b3)
      t << (b0 ^ G2X[b1] ^ G3X[b2] ^ b3)
      t << (b0 ^ b1 ^ G2X[b2] ^ G3X[b3])
      t << (G3X[b0] ^ b1 ^ b2 ^ G2X[b3])
    }
    @state = t
  end
  protected :mixColumns

  def imixColumns
    t = ""
    (0..3).each { |j| i = j*4
      b0 = @state[i]; b1 = @state[i+1]; b2 = @state[i+2]; b3 = @state[i+3]
      t << (GEX[b0] ^ GBX[b1] ^ GDX[b2] ^ G9X[b3])
      t << (G9X[b0] ^ GEX[b1] ^ GBX[b2] ^ GDX[b3])
      t << (GDX[b0] ^ G9X[b1] ^ GEX[b2] ^ GBX[b3])
      t << (GBX[b0] ^ GDX[b1] ^ G9X[b2] ^ GEX[b3])
    }
    @state = t
  end
  protected :imixColumns

  # Combine -- shiftRows, subBytes -- as one method
  def subShiftRows
    @state[0], @state[4], @state[8], @state[12] = 
      S_BOX[@state[0]], S_BOX[@state[4]], S_BOX[@state[8]], S_BOX[@state[12]]
    @state[1], @state[5], @state[9], @state[13] = 
      S_BOX[@state[5]], S_BOX[@state[9]], S_BOX[@state[13]], S_BOX[@state[1]]
    @state[2], @state[6], @state[10], @state[14] = 
      S_BOX[@state[10]], S_BOX[@state[14]], S_BOX[@state[2]], S_BOX[@state[6]]
    @state[3], @state[7], @state[11], @state[15] = 
      S_BOX[@state[15]], S_BOX[@state[3]], S_BOX[@state[7]], S_BOX[@state[11]]
  end
  protected :subShiftRows

  # Combine -- shiftRows, subBytes, addRoundkey -- as one method
  def lastEncryptRound
     i = 16*@nr
    @state[0], @state[4], @state[8], @state[12] = 
      S_BOX[@state[0]] ^ @w[i], S_BOX[@state[4]] ^ @w[i+4],
      S_BOX[@state[8]] ^ @w[i+8], S_BOX[@state[12]] ^ @w[i+12]
    @state[1], @state[5], @state[9], @state[13] = 
      S_BOX[@state[5]] ^ @w[i+1], S_BOX[@state[9]] ^ @w[i+5],
      S_BOX[@state[13]] ^ @w[i+9], S_BOX[@state[1]] ^ @w[i+13]
    @state[2], @state[6], @state[10], @state[14] = 
      S_BOX[@state[10]] ^ @w[i+2], S_BOX[@state[14]] ^ @w[i+6],
      S_BOX[@state[2]] ^ @w[i+10], S_BOX[@state[6]] ^ @w[i+14]
    @state[3], @state[7], @state[11], @state[15] = 
      S_BOX[@state[15]] ^ @w[i+3], S_BOX[@state[3]] ^ @w[i+7],
      S_BOX[@state[7]] ^ @w[i+11], S_BOX[@state[11]] ^ @w[i+15]
  end
  protected :lastEncryptRound

  # Combine -- ishiftRows, isubBytes, addRoundkey -- as one method
  def decryptSubRound(n)
     i = 16*n
    @state[0], @state[4], @state[8], @state[12] = 
      IS_BOX[@state[0]] ^ @w[i], IS_BOX[@state[4]] ^ @w[i+4],
      IS_BOX[@state[8]] ^ @w[i+8], IS_BOX[@state[12]] ^ @w[i+12]
    @state[1], @state[5], @state[9], @state[13] = 
      IS_BOX[@state[13]] ^ @w[i+1], IS_BOX[@state[1]] ^ @w[i+5],
      IS_BOX[@state[5]] ^ @w[i+9], IS_BOX[@state[9]] ^ @w[i+13]
    @state[2], @state[6], @state[10], @state[14] = 
      IS_BOX[@state[10]] ^ @w[i+2], IS_BOX[@state[14]] ^ @w[i+6],
      IS_BOX[@state[2]] ^ @w[i+10], IS_BOX[@state[6]] ^ @w[i+14]
    @state[3], @state[7], @state[11], @state[15] = 
      IS_BOX[@state[7]] ^ @w[i+3], IS_BOX[@state[11]] ^ @w[i+7],
      IS_BOX[@state[15]] ^ @w[i+11], IS_BOX[@state[3]] ^@w[i+15]
  end
  protected :decryptSubRound

  def addRoundKey(n)
    j = n*16;  (0..15).each { |i| @state[i] ^= @w[i+j] }
  end
  protected :addRoundKey

  def key_expansion(key)
    0.upto(@nk*4-1) { |i| @w[i] = key[i] }
    @nk.upto(@nb*(@nr+1)-1) { |i|
      j = i*4 ; k = j-(@nk*4) 
      t0, t1, t2, t3 = @w[j-4], @w[j-3], @w[j-2], @w[j-1] 
      if (i % @nk == 0)
        t0, t1, t2, t3 =
        S_BOX[t1] ^ RCON[i/@nk - 1], S_BOX[t2], S_BOX[t3], S_BOX[t0]
      elsif (@nk > 6) && (i % @nk == 4)
        t0, t1, t2, t3 = S_BOX[t0], S_BOX[t1], S_BOX[t2], S_BOX[t3]
      end
      @w[j], @w[j+1], @w[j+2], @w[j+3] = 
        @w[k] ^ t0, @w[k+1] ^ t1, @w[k+2] ^ t2, @w[k+3] ^ t3
    }	
  end
  protected :key_expansion

  def block_encrypt
    addRoundKey 0
    1.upto(@nr-1) { |n| subShiftRows; mixColumns; addRoundKey n }
    lastEncryptRound
    @state
  end
  protected :block_encrypt

  def block_decrypt
    addRoundKey @nr
    (@nr-1).downto(1) { |n| decryptSubRound n; imixColumns }
    decryptSubRound 0 
    @state
  end
  protected :block_decrypt

  def xor(a,b);  c = ""; 16.times {|i| c << (a[i] ^ b[i]).chr }; c  end
  protected :xor

  def cipher_encrypt(block)
		@state = block.dup
    case @mode
    when 'ECB'; block_encrypt
    when 'CBC'; @state = xor(block, @iv); @iv = block_encrypt
    when 'OFB'; @state = @iv.dup; @iv = block_encrypt; xor(@iv, block)
    when 'CFB'; @state = @iv.dup; @iv = xor(block_encrypt, block)
    end
  end

  def cipher_decrypt(block)
		@state = block.dup
    case @mode
    when 'ECB'; block_decrypt
    when 'CBC'; o = xor(block_decrypt, @iv); @iv = block; o
    when 'OFB'; @state = @iv.dup; @iv = block_encrypt; xor(@iv, block)
    when 'CFB'; @state = @iv.dup; o = xor(block_encrypt, block); @iv = block; o
    end
  end

  def encrypt_buffer(buffer)
    ct = ""; block = ""
    buffer.each_byte { |char| block << char
      if block.length == 16 then ct << cipher_encrypt(block); block = "" end
    }
    m = 16 - block.length % 16
    ct << (m == 16 ? 0 : cipher_encrypt(block << m.chr * m))
  end

  def decrypt_buffer(buffer)
    pt = ""; block = ""
    buffer.each_byte { |char|; block << char
      if block.length == 16 then pt << cipher_decrypt(block); block = "" end
    }
    if block.length == 0
      c = pt[-1]
      c.chr * c == pt[-c..-1] ? pt[0..-(c+1)] : (raise "Bad Block Padding")
    else pt end
  end

  def init_aes(key_length, mode, key, iv = nil)
    @iv = "\000" * 16
    @iv = iv if iv
    @nb = 4; @nk = 4; @nr = 10; @mode = 'ECB'
    @state = nil
    @w = []
    case key_length
    when 128; @nk = 4; @nr = 10
    when 192; @nk = 6; @nr = 12
    when 256; @nk = 8; @nr = 14
    else raise 'Bad Key length'
    end
    case mode
    when 'ECB', 'CBC' , 'OFB' , 'CFB'; @mode = mode
    else raise 'Bad AES mode'
    end
    key_expansion key
  end

  def initialize(key_length, mode, key, iv = nil)
    init_aes(key_length, mode, key, iv)
  end
  
end # class aes
