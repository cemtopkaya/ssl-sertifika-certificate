# İletişimi Şifreli Yapmanın Yolları

## Gizli anahtarlı şifreleme (simetrik şifreleme)
Gizli anahtarlı şifreleme ya da simetrik şifreleme, kriptografik yöntemlerden, 
hem şifreleme hem de deşifreleme işlemi için aynı anahtarı kullanan kripto sistemlere verilen isimdir. 
https://www.sciencedirect.com/topics/computer-science/private-key-encryption

Açık anahtarlı şifreleme, şifre ve deşifre işlemleri için farklı anahtarların kullanıldığı bir şifreleme sistemidir.
Haberleşen taraflardan her birinde birer çift anahtar bulunur.
Bu anahtar çiftlerini oluşturan anahtarlardan biri gizli anahtar diğeri açık (gizli olmayan) anahtardır.
Bu anahtarlardan bir tanesiyle şifreleme yapılırken diğeriyle de şifre çözme işlemi gerçekleştirilir. 
Bu iki anahtar çifti matematiksel olarak birbirleriyle bağlantılıdır.
https://www.sciencedirect.com/topics/computer-science/public-key-encryption
 
Önce SSL sonra üstüne TLS geliştirildi. Güvenli haberleşme için anahtarların değişimini TLS üstünden sağlıyoruz.
Asimetrik şifreleme için gizli ve açık anahtar çiftini oluşturacağız.
 
 ##### Gizli Anahtar (Private Key)
   - Sadece sunucunun bildiği ve kimseyle paylaşılmayacak dosyadır
   - `-----BEGIN PRIVATE KEY-----` satırıyla başlayan dosyadır
   - `.pem` veya `.crt` uzantili olabilir 
   - Sadece key dosyası üretmek için `genrsa` anahtarı kullanılır 
   - 2048 bit uzunluklu şifreleme kullanılacak

```shell
$ openssl genrsa -out gizli_anahtar.key 2048
``` 
 
 ##### Acik Anahtar (Public Key) 
   - Şifreli bir şekilde konuşmak istediğimiz istemcilerle paylaşıyoruz
   - `-----BEGIN CERTIFICATE-----` diye başlayan dosyadır
   - `.pem` veya `.crt` uzantili olabilir 
   - Açık anahtar üreteceğimiz için `req -x509` anahtarı kullanılır 

#### Dosya Uzantilari ve Tanimlari
Apache ile çalışacak normal bir PEM dosyasını bir PFX (PKCS # 12) dosyasına dönüştürebilir ve Tomcat veya IIS ile kullanabilirsiniz.

# Komutlar
### Dosyalari Kontrol Etmek
##### Gizli ve Acik Anahtarlari & CSR Dosyalari Eslesiyor mu?
Gizli ve acik anahtarlarin modulus kisimlarinin MD5 ile hash kodlari aynıysa CRT ve KEY dosyalari birbiriyle bağlı ve sorunsuz çalışacaklar demektir. Aşağıdaki çıktıya göre hem CRT hem KEY dosyalarının modulus kısımlarının HASH kodları aynı değerde **c35ef1503739cee6f991090f8c908d21**
Ayni sekilde CSR dosyasını da bu eşleşmenin içine dahil edebiliriz.

![Modulus kismini gormek icin tiklayiniz](https://user-images.githubusercontent.com/261946/94993001-89333580-0596-11eb-9af1-ad89fd69be43.png)


```
$ openssl rsa -noout -modulus -in sunucu-gizli.key | openssl md5
(stdin)= cf70593bf4bb4eb3e6da59b6f41a87c6

$ openssl x509 -noout -modulus -in sunucu-acik.crt | openssl md5
(stdin)= cf70593bf4bb4eb3e6da59b6f41a87c6

$ openssl req -noout -modulus -in sunucu-istek.csr | openssl md5 
(stdin)= cf70593bf4bb4eb3e6da59b6f41a87c6
```

##### Certificate Signing Request (CSR) Dosyasini Kontrol
```openssl req -text -noout -verify -in CSR.csr```

##### Gizli Anahtari Kontrol 
```openssl rsa -check -in privateKey.key```

##### Check a certificate
```openssl x509 -text -noout -in certificate.crt```

##### PKCS#12 (.pfx or .p12) Dosyasini Kontrol
```openssl pkcs12 -info -in keyStore.p12```

# Kok Sertifikasi Uretimi

#### Sunucu sertifikasinin gizli anahtarini olusturuyoruz

```
$ openssl genrsa -out ./cikti/sunucu-gizli.key 2048
```

#### Sunucu sertifikasinin acik anahtarini olusturuyoruz
- public anahtar uretimi icin `req -x509`
- acik gizli anahtar icin `-nodes`
- 10 Yillik suresi olsun diye `-days 3650`
- Sertifika bilgi ve ayarlari icin `-config openssl_root.cnf`
- 2048 bit uzunlugunda yeni gizli anahtar uretmesi icin `-newkey rsa:2048`
- private key'in kaydedilecegi dosya yolu ve adi icin `-keyout ./rootCA.key`
- public key'in kaydedilecegi dosya yolu ve adi icin `-out ./rootCA.crt`
  
``` 
openssl req -x509                     \
  -new -nodes                         \
  -days 3650                          \
  -sha256                             \
  -newkey rsa:2048                    \
  -config kok-sertifika-bilgileri.cnf \
  -keyout ./cikti/rootCA.key          \
  -out ./cikti/rootCA.crt
```

### Acik anahtari kontrol edelim
```
$ openssl x509 -noout -text -in ./cikti/araCA-acik.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            aa:f3:9a:86:5d:7b:f6:da
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = TR, L = ISTANBUL, O = En Kaliteli Sertifika Firmasi Ltd. Sti., OU = Sertifika Uretim Departumani, CN = VeriSigndan DA Iyi Root CA Firmasiyiz
        Validity
            Not Before: Oct  3 05:52:40 2020 GMT
```

### Gizli anahtari kontrol edelim
```
 $ openssl rsa -check -in ./cikti/sunucu-gizli.key

 RSA key ok
 writing RSA key
 -----BEGIN RSA PRIVATE KEY-----
 MIIEpAIBAAKCAQEA6MzEjqSJaKbd8fpvVKj9CgrWTTVoGWD05pzJxmfM1SsMIes3
 5v852U3KpHJdD6K1pzcMwZPPQNaAzKYGGcwWMqOxFapR6TiojQp2t4BN3lFTo2g0
 ...................
```

### CSR Dosyasi Olusturmak
CSR Dosyamiza gizli anahtarimizi ve serfifika bilgilerini yazip sertifika otoritesine acik anahtari olusturmasi icin verecegiz

```
$ openssl req                         \
  -new -key ./cikti/sunucu-gizli.key  \
  -out ./cikti/sunucu-istek.csr       \
  -config "../1. kendinden-imzali/sunucu-sertifika-bilgileri.cnf"
```

#### CSR Dosyasina Bakalim
```
$ openssl req -text -noout -verify -in sunucu-istek.csr 
verify OK
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = TR, ST = Istanbul, L = Tuzla, O = Yeni E-Ticaret Sitemiz A.S., OU = E-Ticaret Gelistirme Bolumu, CN = *.hersey1lira.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:e8:cc:c4:8e:a4:89:68:a6:dd:f1:fa:6f:54:a8:
```

#### Serfifikamizi .p12 Dosyasina Donusturelim

```
$ openssl pkcs12 -export   \
  -out ./sunucu.pfx        \
  -inkey sunucu-gizli.key  \
  -in sunucu-acik.crt      \
  -certfile araCA-acik.crt

```
![PKCS Formatina Donusturme](https://user-images.githubusercontent.com/261946/95008906-70726080-0626-11eb-817c-f7db21e66e17.png)

Iceriginde iki acik anahtar bir gizli anahtar olacak sekilde PKCS dosyasinin detaylarina bakabiliriz:

```
 openssl pkcs12 -info -in sunucu.pfx
Enter Import Password:
MAC: sha1, Iteration **2048**
MAC length: 20, salt length: 8
PKCS7 Encrypted data: pbeWithSHA1And40BitRC2-CBC, Iteration 2048
Certificate bag
Bag Attributes
    localKeyID: AF 66 B1 C1 B2 8D 63 8C 22 C0 3E A8 7C 0E A3 71 FA E7 2B 97 
subject=C = TR, ST = Istanbul, L = Tuzla, O = Yeni E-Ticaret Sitemiz A.S., OU = E-Ticaret Gelistirme Bolumu, CN = *.hersey1lira.com

issuer=C = TR, L = KARS, O = Kaliteli Sertifika Ureten Bayi (Ara CA) Firmasi Ltd. Sti., OU = Sertifika Uretici Birimi (Toplam 5 kisi calisiyor :), CN = Spor Toto Bayisi Gibi ARA CA Firmasiyiz

-----BEGIN CERTIFICATE-----
MIID5zCCAs8CCQCq85qGXXv22zANBgkqhkiG9w0BAQsFADCB0TELMAkGA1UEBhMC
VFIxDTALBgNVBAcMBEtBUlMxQjBABgNVBAoMOUthbGl0ZWxpIFNlcn..........
DFHva+NR8HOfCzepiWykYGECWY6zMWVfNrfOx+at1QZptrqagNyZRMrTXQ==
-----END CERTIFICATE-----
Certificate bag
Bag Attributes: <No Attributes>
subject=C = TR, L = KARS, O = Kaliteli Sertifika Ureten Bayi (Ara CA) Firmasi Ltd. Sti., OU = Sertifika Uretici Birimi (Toplam 5 kisi calisiyor :), CN = Spor Toto Bayisi Gibi ARA CA Firmasiyiz

issuer=C = TR, L = ISTANBUL, O = En Kaliteli Sertifika Firmasi Ltd. Sti., OU = Sertifika Uretim Departumani, CN = VeriSigndan DA Iyi Root CA Firmasiyiz

-----BEGIN CERTIFICATE-----
MIIEaTCCA1GgAwIBAgIJAKrzmoZde/baMA0GCSqGSIb3DQEBCwUAMIGpMQswCQYD
VQQGEwJUUjERMA8GA1UEBwwISVNUQU5CVUwxMDAuB......................
AJgTPYnzYx0zzvPmYLsyPCzNT7hVhGuG/1NTaeT1MYwKRNn3hWVUGF3EUFP0PXkp
xTld6XTW+gWGG0iD/EDBf6lL0XWpu6JhwRTSxWE=
-----END CERTIFICATE-----
PKCS7 Data
Shrouded Keybag: pbeWithSHA1And3-KeyTripleDES-CBC, Iteration 2048
Bag Attributes
    localKeyID: AF 66 B1 C1 B2 8D 63 8C 22 C0 3E A8 7C 0E A3 71 FA E7 2B 97 
Key Attributes: <No Attributes>
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----BEGIN ENCRYPTED PRIVATE KEY-----
MIIFHDBOBgkqhkiG9w0BBQ0wQTApBgkqhkiG9w0BBQwwHAQI+nVsGAw4B+YCAggA
MAwGCCqGSIb3DQIJBQAwFAYIKoZIhvcNAwc............................
5w0IpC1R7CkFo1AndBrroUV3DJdHMpiWLyCE/FpxN1Hb1DIqo0O7ZqsK516aD28x
ZzxXbM0jneNQFkSnG10uIA==
-----END ENCRYPTED PRIVATE KEY-----
```

#### Serfifikamizi JKS (Java Keystore) Dosyasina Donusturelim
JKS Dosyasi takma adlar altinda birden fazla sertifika bilgisini iceren klasor gibi dusunulebilinir.
Basitce alice.p12 dosyasini alice.jks dosyasina donusturmek icin:
```
So in fact in our case, converting from alice.p12 to alice.jks is extremely simple:

alice Takma adli bos bir JKS deposu olusturmak icin:
$ keytool -genkey -alias alice -keystore alice.jks

alice Takma adini JKS Deposundan silmek icin:
$ keytool -delete -alias alice -keystore alice.jks

alice.p12 Dosyasindaki icerigi alice.jks dosyasina aktaralim:
$ keytool -v -importkeystore -srckeystore alice.p12 -srcstoretype PKCS12 -destkeystore truststore.jks -deststoretype JKS
```

#### JKS Dosyasına Bir Sertifika (örn. Kök Sertifikamızı) Ekleyelim
JKS nin bir dizin sertifika dosyalarımızın (public ve private) dosya olduğunu düşünürseniz, JKS dizinine dosya kopyalamak gibi işlem yapmış olacağız.
Farkı ise ekstra bir takma ad kullanabilmemiz. Alias sayesinde JKS içeriğine baktığımızda ekli dosyanın ne olduğuna dair bir fikir sahibi olabiliriz.

```
$ keytool -keystore truststore.jks -alias koksertifika -import -file rootCa.crt
```

```
-importkeystore [-v]
             [-srckeystore ]      [-destkeystore ]
             [-srcstoretype ]     [-deststoretype ]
             [-srcstorepass ]     [-deststorepass ]
             [-srcprotected]      [-destprotected]
             [-srcprovidername ]  [-destprovidername ]
             [-srcalias           [-destalias ]
             [-srckeypass ]       [-destkeypass ]]
             [-noprompt]
             [-providerclass]
             [-providerarg ]
             [-providerpath ]

$ keytool -importkeystore --help
keytool -importkeystore [OPTION]...

Imports one or all entries from another keystore

Options:

 -srckeystore <keystore>   source keystore name
 -destkeystore <keystore>  destination keystore name
 -srcstoretype <type>      source keystore type
 -deststoretype <type>     destination keystore type
 -srcstorepass <arg>       source keystore password
 -deststorepass <arg>      destination keystore password
 -srcprotected             source keystore password protected
 -destprotected            destination keystore password protected
 -srcprovidername <name>   source keystore provider name
 -destprovidername <name>  destination keystore provider name
 -srcalias <alias>         source alias
 -destalias <alias>        destination alias
 -srckeypass <arg>         source key password
 -destkeypass <arg>        destination key password
 -noprompt                 do not prompt
 -addprovider <name>       add security provider by name (e.g. SunPKCS11)
   [-providerarg <arg>]      configure argument for -addprovider
 -providerclass <class>    add security provider by fully-qualified class name
   [-providerarg <arg>]      configure argument for -providerclass
 -providerpath <list>      provider classpath
 -v                        verbose output
```

Sifre bilgilerini komut satirina yazmazsak calistirdigimizda bize soracaktir:

```
$ keytool -importkeystore \
  -srckeystore ./sunucu.pfx \
  -srcstoretype PKCS12 \
  -srcalias 1 \
  -srcstorepass q1w2e3r4 \
  -destkeystore ./sunucu_keystore.jks \
  -deststoretype JKS \
  -deststorepass sifre6karakter \
  -destalias hersey_1_lira_takma_ad
```

#### Olusan JKS dosyasinin icerigine Bakalim
```
$ keytool -v -list -keystore sunucu_keystore.jks -storepass sifre6karakter
```
![PKCS to JKS](https://user-images.githubusercontent.com/261946/95008912-76684180-0626-11eb-8a9b-4fb05234a25d.png)

##### PKCS Dosyasindaki takma adi bulmak icin su komutu calistirabiliriz:

```
$ keytool -v -list -storetype pkcs12 -keystore sunucu.pfx
```
![PKCS icindeki takma adi bulmak](https://user-images.githubusercontent.com/261946/95008910-736d5100-0626-11eb-9bbb-2943a5a7f735.png)

# Sertifikanin Sunucudan Gelisi
```
openssl s_client -connect www.paypal.com:443
```
![SSL Dogrulama](https://user-images.githubusercontent.com/261946/95008902-6b151600-0626-11eb-8431-9e46fa3c09c4.png)
