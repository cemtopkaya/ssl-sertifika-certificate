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

# CSR Dosyasina gizli anahtarimizi ve serfifika bilgilerini yazip 
# sertifika otoritesine acik anahtari olusturmasi icin verecegiz
openssl req                           \
  -new -key ./cikti/sunucu-gizli.key  \
  -out ./cikti/sunucu-istek.csr       \
  -config ../kendinden-imzali/sunucu-sertifika-bilgileri.cnf 

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
