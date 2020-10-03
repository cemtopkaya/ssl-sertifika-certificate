rm *.crt *.key *.csr

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
openssl req -x509 \
  -new -nodes \
  -days 3650 \
  -sha256 \
  -config kok-sertifika-bilgileri.cnf \
  -newkey rsa:2048 \
  -keyout ./rootCA.key \
  -out ./rootCA.crt


# Sunucu sertifikasinin gizli anahtarini olusturuyoruz
openssl genrsa -out ./sunucu-gizli.key 2048

# CSR Dosyasina gizli anahtarimizi ve serfifika bilgilerini yazip 
# sertifika otoritesine acik anahtari olusturmasi icin verecegiz
openssl req \
  -new -key ./sunucu-gizli.key \
  -out ./sunucu-istek.csr \
  -config ../kendinden-imzali/sunucu-sertifika-bilgileri.cnf 

# CA tarafindan imzali acik anahtarimiz olusturulacak
openssl x509 \
  -req \
  -days 3650 \
  -sha256 \
  -CA ./rootCA.crt \
  -CAkey ./rootCA.key     \
  -CAcreateserial         \
  -in ./sunucu-istek.csr  \
  -extensions v3_req      \
  -extfile ./kok-sertifika-bilgileri.cnf \
  -out ./sunucu-acik.crt
