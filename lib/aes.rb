#!/usr/bin/env ruby

=begin
ruby-aes version 1.8.0
Written by Alex Boussinet <dbug@wanadoo.fr>

API:

This is the main API file for ruby-aes.
=end

class Aes

  require 'aes_alg'

  @@aes = nil
  @@bs = 4096

  def Aes.help
    puts <<EOH
Valid modes are:
    * ECB (Electronic Code Book)
    * CBC (Cipher Block Chaining)
    * OFB (Output Feedback)
    * CFB (Cipher Feedback)

Valid key length:
    * 128 bits
    * 192 bits
    * 256 bits

API calls:
  Default key_length: 128
  Default mode: 'ECB'
  Default IV: 16 null chars ("00" * 16 in hex format)
  Default key: 16 null chars ("00" * 16 in hex format)
  Default input text: "PLAINTEXT"

    Aes.check_key(key_string, key_length)
    Aes.check_iv(iv_string)
    Aes.check_kl(key_length)
    Aes.check_mode(mode)
    Aes.init_aes(key_length, mode, key, iv)
    Aes.encrypt_buffer(key_length, mode, key, iv, buffer) # padding
    Aes.decrypt_buffer(key_length, mode, key, iv, buffer) # padding
    Aes.encrypt_block(key_length, mode, key, iv, block) # no padding
    Aes.decrypt_block(key_length, mode, key, iv, block) # no padding
    Aes.encrypt_file(key_length, mode, key, iv, filein, fileout)
    Aes.decrypt_file(key_length, mode, key, iv, filein, fileout)
    Aes.help
    Aes.bs=(bs)
    Aes.bs()

EOH
  end

  def Aes.bs(); return @@bs end
  def Aes.bs=(bs); @@bs = bs.to_i; @@bs==0 ? 4096 : @@bs = @@bs - @@bs%16 end

  def Aes.check_key(key_string, kl = 128)
    k = key_string.length
    raise "Bad key string or bad key length" if (k != kl/8) && (k != kl/4)
    hex = (key_string =~ /[a-f0-9A-F]{#{k}}/) == 0 && (k == kl/4)
    bin = ! hex
    if ! (([32, 48, 64].include?(k) && hex) ||
	  ([16, 24, 32].include?(k) && bin))
      raise "Bad key string"
    end
    hex ? [key_string].pack("H*") : key_string
  end

  def Aes.check_iv(iv_string)
    k = iv_string.length
    hex = (iv_string =~ /[a-f0-9A-F]{#{k}}/) == 0
    bin = ! hex
    if k == 32 && hex
      return [iv_string].pack("H*")
    elsif k == 16 && bin
      return iv_string
    else
      raise "Bad IV string"
    end
  end

  def Aes.check_mode (mode)
    case mode
    when 'ECB', 'CBC', 'OFB', 'CFB'
    else raise "Bad cipher mode"
    end
    mode
  end

  def Aes.check_kl(key_length)
    case key_length
    when 128, 192, 256
    else raise "Bad key length"
    end
    key_length
  end

  def Aes.init_aes(keyl, mode, key, iv)
    unless @@aes
      @@aes = AesAlg.new(Aes.check_kl(keyl), Aes.check_mode(mode),
			 Aes.check_key(key, keyl), iv ? Aes.check_iv(iv) : nil)
    else
      @@aes.init_aes(Aes.check_kl(keyl), Aes.check_mode(mode),
		     Aes.check_key(key, keyl), iv ? Aes.check_iv(iv) : nil)
    end
  end

  def Aes.encrypt_block(keyl, mode, key, iv, block = "DEFAULT PLAINTXT")
    raise "Bad Block size" if block.length < 16 || block.length > 16
    Aes.init_aes(keyl, mode, key, iv)
    @@aes.cipher_encrypt(block)
  end

  def Aes.decrypt_block(keyl, mode, key, iv, block = "DEFAULT PLAINTXT")
    raise "Bad Block size" if block.length < 16 || block.length > 16
    Aes.init_aes(keyl, mode, key, iv)
    @@aes.cipher_decrypt(block)
  end

  def Aes.encrypt_buffer(keyl, mode, key, iv, buffer = "PLAINTEXT")
    Aes.init_aes(keyl, mode, key, iv)
    @@aes.encrypt_buffer(buffer)
  end

  def Aes.decrypt_buffer(keyl, mode, key, iv, buffer = "DEFAULT PLAINTXT")
    raise "Bad Block size" if buffer.length < 16
    Aes.init_aes(keyl, mode, key, iv)
    @@aes.decrypt_buffer(buffer)
  end

  def Aes.encrypt_file(keyl, mode, key, iv, filein = nil, fileout = nil)
    Aes.init_aes(keyl, mode, key, iv)
    fin = filein.nil? ? STDIN : File.open(filein, "rb")
    fout = fileout.nil? ? STDOUT : File.open(fileout, "wb")
    begin
      while in_buffer = fin.read(@@bs)
	out_buffer = @@aes.encrypt_buffer(in_buffer)
	fout.write(out_buffer)
      end
    ensure
      fin.close unless fin.nil? || fin == STDIN
      fout.close unless fout.nil? || fout == STDOUT
    end
  end

  def Aes.decrypt_file(keyl, mode, key, iv, filein = "-", fileout = nil)
    Aes.init_aes(keyl, mode, key, iv)
    fin = filein.nil? ? STDIN : File.open(filein, "rb")
    fout = fileout.nil? ? STDOUT : File.open(fileout, "wb")
    begin
      while in_buffer = fin.read(@@bs)
	out_buffer = @@aes.decrypt_buffer(in_buffer)
	fout.write(out_buffer)
      end
    ensure
      fin.close unless fin.nil? || fin == STDIN
      fout.close unless fout.nil? || fout == STDOUT
    end
  end

end # end Aes
