#!/bin/sh

# Daha onceden olusturulmus sertifika kalintilarini temizler
rm ./cikti/*.*

# Iletisimi Sifreli Yapmanin Yollari
#
# Gizli anahtarlı şifreleme ya da simetrik şifreleme, kriptografik yöntemlerden, 
# hem şifreleme hem de deşifreleme işlemi için aynı anahtarı kullanan kripto sistemlere verilen isimdir. 
# https://www.sciencedirect.com/topics/computer-science/private-key-encryption
#
# Açık anahtarlı şifreleme, şifre ve deşifre işlemleri için farklı anahtarların kullanıldığı bir şifreleme sistemidir.
# Haberleşen taraflardan her birinde birer çift anahtar bulunur.
# Bu anahtar çiftlerini oluşturan anahtarlardan biri gizli anahtar diğeri açık (gizli olmayan) anahtardır.
# Bu anahtarlardan bir tanesiyle şifreleme yapılırken diğeriyle de şifre çözme işlemi gerçekleştirilir. 
# Bu iki anahtar çifti matematiksel olarak birbirleriyle bağlantılıdır.
# https://www.sciencedirect.com/topics/computer-science/public-key-encryption
# 
# Once SSL sonra ustune TLS gelistirildi. Guvenli haberlesme icin anahtarlarin degisimini TLS ustunden sagliyoruz.
# Asimetrik sifreleme icin gizli ve acik anahtar ciftini olusturacagiz.
# 
# Gizli Anahtar (Private Key)
#   > Sadece sunucunun bildigi ve kimseyle paylasilmayacak dosyadir
#   > -----BEGIN PRIVATE KEY----- satiriyla baslayan dosyadir
#   > .pem veya .crt uzantili olabilir 
#   > Sadece key dosyasi uretmek icin "genrsa" anahtari kullanilir 
#   > 2048 bit uzunluklu sifreleme kullanilacak
#   $ openssl genrsa -out gizli_anahtar.key 2048
# 
# 
# Acik Anahtar (Public Key) 
#   > Sifreli bir sekilde konusmak istedigimiz istemcilerle paylasiyoruz
#   > -----BEGIN CERTIFICATE----- diye baslayan dosyadir
#   > .pem veya .crt uzantili olabilir 
#   > Acik anahtar uretecegimiz icin "req -x509" anahtari kullanilir 
# 
openssl req -x509                                    \
        -out ./cikti/sunucu_sertifikasi.crt                  \
        -keyout ./cikti/sunucu_sertifikasi.key               \
        -newkey rsa:2048                             \
        -nodes -sha256                               \
        -subj /CN=bilgisayaradi                      \
        -extensions v3_req                           \
        -config ./sunucu-sertifika-bilgileri.cnf