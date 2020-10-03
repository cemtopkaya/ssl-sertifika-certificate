#!/bin/sh

# Daha onceden olusturulmus sertifika kalintilarini temizler
rm ./cikti/*.*

# Kok Sertifikasi Uretimi
#
# public anahtar uretimi icin `req -x509`
# acik gizli anahtar icin `-nodes`
# 10 Yillik suresi olsun diye `-days 3650`
# Sertifika bilgi ve ayarlari icin `-config openssl_root.cnf`
# 2048 bit uzunlugunda yeni gizli anahtar uretmesi icin `-newkey rsa:2048`
# private key'in kaydedilecegi dosya yolu ve adi icin `-keyout ./rootCA.key`
# public key'in kaydedilecegi dosya yolu ve adi icin `-out ./rootCA.crt`
# 
openssl req -x509                     \
  -new -nodes                         \
  -days 3650                          \
  -sha256                             \
  -newkey rsa:2048                    \
  -config kok-sertifika-bilgileri.cnf \
  -keyout ./cikti/rootCA.key          \
  -out ./cikti/rootCA.crt


# Sunucu sertifikasinin gizli anahtarini olusturuyoruz
openssl genrsa -out ./cikti/sunucu-gizli.key 2048

# Gizli anahtari kontrol edelim
#
# $ openssl rsa -in ./cikti/sunucu-gizli.key -check
# RSA key ok
# writing RSA key
# -----BEGIN RSA PRIVATE KEY-----
# MIIEpAIBAAKCAQEA6MzEjqSJaKbd8fpvVKj9CgrWTTVoGWD05pzJxmfM1SsMIes3
# 5v852U3KpHJdD6K1pzcMwZPPQNaAzKYGGcwWMqOxFapR6TiojQp2t4BN3lFTo2g0
# ...................
#
openssl rsa -in ./cikti/sunucu-gizli.key -check

# CSR Dosyasina gizli anahtarimizi ve serfifika bilgilerini yazip 
# sertifika otoritesine acik anahtari olusturmasi icin verecegiz
# 
# $ openssl req -noout -text -in sunucu-istek.csr 
# Certificate Request:
#     Data:
#         Version: 1 (0x0)
#         Subject: C = TR, ST = Istanbul, L = Tuzla, O = Yeni E-Ticaret Sitemiz A.S., OU = E-Ticaret Gelistirme Bolumu, CN = *.hersey1lira.com
#         Subject Public Key Info:
#             Public Key Algorithm: rsaEncryption
#                 RSA Public-Key: (2048 bit)
#                 Modulus:
#                     00:e8:cc:c4:8e:a4:89:68:a6:dd:f1:fa:6f:54:a8:
# ...................
# 
openssl req                           \
  -new -key ./cikti/sunucu-gizli.key  \
  -out ./cikti/sunucu-istek.csr       \
  -config ../kendinden-imzali/sunucu-sertifika-bilgileri.cnf 

# CSR Icerigini oku
# -noout > Sadece okunabilir kismi goruntulemek icin (----BEGIN CERTIFICATE ile baslayan sertifika icergini goruntuler)
openssl req -noout -text -in ./cikti/sunucu-istek.csr

# CA tarafindan imzali acik anahtarimiz olusturulacak
openssl x509                    \
  -req                          \
  -days 3650                    \
  -sha256                       \
  -CA ./cikti/rootCA.crt        \
  -CAkey ./cikti/rootCA.key     \
  -in ./cikti/sunucu-istek.csr  \
  -CAcreateserial               \
  -extfile ./kok-sertifika-bilgileri.cnf \
  -extensions v3_req            \
  -out ./cikti/sunucu-acik.crt
