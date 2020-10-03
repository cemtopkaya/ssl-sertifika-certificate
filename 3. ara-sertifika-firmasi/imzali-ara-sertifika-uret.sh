#!/bin/sh

# Daha onceden olusturulmus sertifika kalintilarini temizler
rm ./cikti/*.*

############################################################### Kok Sertifikasi Uretimi
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
  -config "../2. kok-sertifika-firmasi/kok-sertifika-bilgileri.cnf" \
  -keyout ./cikti/rootCA-gizli.key          \
  -out ./cikti/rootCA-acik.crt


############################################################### ARA Sertifika Uretimi
# Sunucu sertifikasinin gizli anahtarini olusturuyoruz
openssl genrsa -out ./cikti/araCA-gizli.key 2048

# Ara Sertifika Yetkilisininin CSR Dosyasina gizli anahtarimizi ve serfifika bilgilerini yazip 
# sertifika otoritesine acik anahtari olusturmasi icin verecegiz
openssl req                           \
  -new -key ./cikti/araCA-gizli.key  \
  -out ./cikti/araCA-istek.csr       \
  -config ./ara-sertifika-bilgileri.cnf 

# CA tarafindan imzali ara sertifika otoristesinin acik anahtari olusturulacak
openssl x509                    \
  -req                          \
  -days 3650                    \
  -sha256                       \
  -CA ./cikti/rootCA-acik.crt        \
  -CAkey ./cikti/rootCA-gizli.key     \
  -in ./cikti/araCA-istek.csr  \
  -CAcreateserial               \
  -extfile ./ara-sertifika-bilgileri.cnf \
  -extensions v3_req            \
  -out ./cikti/araCA-acik.crt


############################################################### Sunucu Sertifika Uretimi
#
# Sunucu sertifikasinin gizli anahtarini olusturuyoruz
openssl genrsa -out ./cikti/sunucu-gizli.key 2048

# CSR Dosyasina gizli anahtarimizi ve serfifika bilgilerini yazip 
# sertifika otoritesine acik anahtari olusturmasi icin verecegiz
openssl req                           \
  -new -key ./cikti/sunucu-gizli.key  \
  -out ./cikti/sunucu-istek.csr       \
  -config "../1. kendinden-imzali/sunucu-sertifika-bilgileri.cnf"

# CA tarafindan imzali acik anahtarimiz olusturulacak
openssl x509                    \
  -req                          \
  -days 3650                    \
  -sha256                       \
  -CA ./cikti/araCA-acik.crt        \
  -CAkey ./cikti/araCA-gizli.key     \
  -in ./cikti/sunucu-istek.csr  \
  -CAcreateserial               \
  -out ./cikti/sunucu-acik.crt
