# Contoso Air - Modernize Edilmiş Havayolu Rezervasyon Demo Uygulaması

Demo ve öğrenme amaçlı kullanılan, modern bulut-native mimari ve Azure en iyi uygulamalarını sergileyen örnek bir havayolu rezervasyon uygulaması.

## 🎯 Proje Genel Bakış

Bu repository, önceden arşivlenmiş [microsoft/ContosoAir](https://github.com/microsoft/ContosoAir) demo projesinin yeniden canlandırılmış ve modernize edilmiş versiyonudur. Uygulama, güncel teknoloji standartları ve bulut-native uygulamaları ile tamamen yeniden inşa edilmiştir ve şunlar için ideal bir referans implementasyon sağlar:

- Node.js ile modern web uygulaması mimarisi
- Azure bulut servisleri entegrasyonu
- Güvenli kimlik doğrulama paternleri
- Kubernetes ile container orkestasyonu
- GitHub Actions ile CI/CD pipeline'ları

## ✨ Temel Özellikler

### Uygulama Özellikleri
- **Uçuş Arama ve Rezervasyon**: Şehirler arası uçuş arama ve rezervasyon tamamlama
- **Kullanıcı Kimlik Doğrulama**: Passport.js ile güvenli giriş sistemi
- **Rezervasyon Yönetimi**: Uçuş rezervasyonlarını görüntüleme ve yönetme
- **Çoklu Dil Desteği**: İngilizce ve İspanyolca ile uluslararasılaştırma (i18n)
- **Responsive Tasarım**: Bootstrap 5 ile mobil uyumlu arayüz
- **İzleme**: Gözlemlenebilirlik için yerleşik Prometheus metrikleri

### Teknik Özellikler
- **Node.js 22**: Optimal performans için en son LTS sürümü
- **Azure CosmosDB**: Ölçeklenebilir veri depolama için MongoDB API 7.0
- **Managed Identity**: Azure servislerine şifresiz kimlik doğrulama
- **Konteynerize**: Tutarlı deployment'lar için Docker desteği
- **Kubernetes Hazır**: HPA desteği ile production-grade K8s manifest'leri
- **CI/CD Pipeline**: GitHub Actions ile otomatik build ve deployment
- **Güvenlik Sağlamlaştırması**: Root olmayan container'lar, kaynak sınırları ve güvenlik context'leri

## 🏗️ Mimari

```
├── src/web/                 # Ana web uygulaması
│   ├── routes/             # Express route handler'ları
│   ├── services/           # İş mantığı katmanı
│   ├── repositories/       # Veri erişim katmanı (CosmosDB)
│   ├── views/              # Handlebars şablonları
│   ├── public/             # Statik dosyalar (CSS, JS, görseller)
│   └── Dockerfile          # Container tanımı
├── infra/k8s/              # Kubernetes manifest'leri
│   ├── k8s-deployment.yaml # Deployment ve Service
│   ├── k8s-hpa.yaml        # Horizontal Pod Autoscaler
│   └── k8s-configmap.yaml  # Yapılandırma
└── .github/workflows/      # CI/CD pipeline'ları
    └── azure-kubernetes-service.yml
```

## 🚀 Modernizasyon Vurguları

Bu proje, Azure DevOps - Görev #1892'de takip edilen kapsamlı bir modernizasyon çalışmasını temsil eder ve şunları içerir:

1. **Teknoloji Stack Güncellemesi**
   - Eski versiyonlardan Node.js 22'ye geçiş yapıldı
   - Modern middleware ile Express 5.x'e güncellendi
   - Identity yönetimi için Azure SDK v4 entegre edildi
   - Tüm bağımlılıklar en son kararlı versiyonlara güncellendi

2. **Kimlik Doğrulama Modernizasyonu**
   - Şifresiz kimlik doğrulama için Azure Managed Identity uygulandı
   - Kod tabanından sabit kodlanmış kimlik bilgileri kaldırıldı
   - Güvenli erişim için DefaultAzureCredential pattern eklendi

3. **Infrastructure as Code**
   - Kubernetes deployment manifest'leri oluşturuldu
   - Horizontal pod autoscaling uygulandı
   - Kaynak talepleri ve sınırları eklendi
   - Health check'ler ve güvenlik context'leri yapılandırıldı

4. **CI/CD Pipeline**
   - Otomatik build'ler için GitHub Actions workflow
   - Azure ACR ile container image oluşturma
   - Azure Kubernetes Service'e otomatik deployment
   - Güvenli deployment'lar için OpenID Connect (OIDC) kimlik doğrulama

5. **Geliştirici Deneyimi**
   - Kapsamlı kurulum dokümantasyonu
   - Net ön koşul gereksinimleri
   - Adım adım deployment rehberi
   - Local geliştirme desteği

Başlamak için, aşağıdaki kurulum talimatlarını takip edin. Bu talimatlar, gerekli Azure kaynaklarını yapılandırma ve uygulamayı yerel olarak çalıştırma konusunda size rehberlik edecektir.

## 📋 Ön Koşullar

- **Node.js**: Versiyon 22.0.0 veya üzeri ([İndir](https://nodejs.org/))
- **Azure CLI**: En son versiyon ([Kurulum](https://docs.microsoft.com/tr-tr/cli/azure/install-azure-cli))
- **POSIX Shell**: bash veya zsh (Linux/macOS/WSL)
- **Azure Aboneliği**: CosmosDB ve diğer servisler için gerekli
- **Docker** (opsiyonel): Konteynerize edilmiş geliştirme için
- **kubectl** (opsiyonel): Kubernetes deployment için

## 🛠️ Başlangıç

### Adım 1: Azure Kaynak Kurulumu

MongoDB API ile Azure CosmosDB hesabı oluşturun ve managed identity kimlik doğrulaması yapılandırın:

```bash
# Benzersiz isimler için rastgele kaynak tanımlayıcı oluştur
RAND=$RANDOM
export RAND
echo "Rastgele kaynak tanımlayıcı: ${RAND}"

# Azure kaynakları için değişkenleri ayarla
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
AZURE_RESOURCE_GROUP_NAME=rg-contosoair$RAND
AZURE_COSMOS_ACCOUNT_NAME=db-contosoair$RAND
AZURE_REGION=eastus

# Kaynak grubu oluştur
az group create \
--name $AZURE_RESOURCE_GROUP_NAME \
--location $AZURE_REGION

# MongoDB API 7.0 ile CosmosDB hesabı oluştur
AZURE_COSMOS_ACCOUNT_ID=$(az cosmosdb create \
--name $AZURE_COSMOS_ACCOUNT_NAME \
--resource-group $AZURE_RESOURCE_GROUP_NAME \
--kind MongoDB \
--server-version 7.0 \
--query id -o tsv)

# Rezervasyon verileri için test veritabanı oluştur
az cosmosdb mongodb database create \
  --account-name $AZURE_COSMOS_ACCOUNT_NAME \
  --resource-group $AZURE_RESOURCE_GROUP_NAME \
  --name test
```

### Adım 2: Managed Identity Yapılandırması

Şifresiz kimlik doğrulama için Azure Managed Identity kurun:

```bash
# Managed identity oluştur
AZURE_COSMOS_IDENTITY_ID=$(az identity create \
--name db-contosoair$RAND-id \
--resource-group $AZURE_RESOURCE_GROUP_NAME \
--query id -o tsv)

# Managed identity principal ID'sini al
AZURE_COSMOS_IDENTITY_PRINCIPAL_ID=$(az identity show \
--ids $AZURE_COSMOS_IDENTITY_ID \
--query principalId \
-o tsv)

# Managed identity'ye DocumentDB rolü ata
az role assignment create \
--role "DocumentDB Account Contributor" \
--assignee $AZURE_COSMOS_IDENTITY_PRINCIPAL_ID \
--scope $AZURE_COSMOS_ACCOUNT_ID

# Uygulama için environment variable'ları export et
export AZURE_COSMOS_CLIENTID=$(az identity show \
--ids $AZURE_COSMOS_IDENTITY_ID \
--query clientId \
-o tsv)
export AZURE_COSMOS_LISTCONNECTIONSTRINGURL=https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP_NAME/providers/Microsoft.DocumentDB/databaseAccounts/$AZURE_COSMOS_ACCOUNT_NAME/listConnectionStrings?api-version=2021-04-15
export AZURE_COSMOS_SCOPE=https://management.azure.com/.default
```

### Adım 3: Uygulamayı Yerel Olarak Çalıştırma

Repository'yi klonlayın ve uygulamayı başlatın:

```bash
# Repository'yi klonla (henüz yapılmadıysa)
git clone https://github.com/karabasosman/contoso-air.git
cd contoso-air

# Web uygulaması dizinine git
cd src/web

# Bağımlılıkları yükle
npm install

# Uygulamayı başlat
npm start
```

Uygulama `http://localhost:3000` adresinde erişilebilir olacaktır.

### Adım 4: Uygulamayı Keşfedin

- **Ana Sayfa**: Öne çıkan destinasyonları ve fırsatları inceleyin
- **Uçuş Ara**: Tarih seçimi ile şehirler arası uçuş arama
- **Uçuş Rezervasyonu**: Rezervasyon sürecini tamamlayın (Azure CosmosDB kurulumu gerektirir)
- **Rezervasyonları Görüntüle**: Rezervasyon geçmişinizi ve fişinizi görün

## 🐳 Docker Deployment

Docker kullanarak uygulamayı build edin ve çalıştırın:

```bash
# Docker image'ı build et
docker build -t contoso-air:latest ./src/web

# Container'ı çalıştır
docker run -p 3000:3000 \
  -e AZURE_COSMOS_CLIENTID=$AZURE_COSMOS_CLIENTID \
  -e AZURE_COSMOS_LISTCONNECTIONSTRINGURL=$AZURE_COSMOS_LISTCONNECTIONSTRINGURL \
  -e AZURE_COSMOS_SCOPE=$AZURE_COSMOS_SCOPE \
  contoso-air:latest
```

## ☸️ Kubernetes Deployment

Azure Kubernetes Service (AKS)'e deploy edin:

```bash
# kubectl context'i ayarla
az aks get-credentials --resource-group <kaynak-grubunuz> --name <aks-cluster-adınız>

# Kubernetes manifest'lerini uygula
kubectl apply -f infra/k8s/

# Deployment durumunu kontrol et
kubectl get pods -l app=contoso-air-web
kubectl get svc contoso-air-web

# Uygulama loglarını görüntüle
kubectl logs -l app=contoso-air-web --tail=50 -f
```

Deployment şunları içerir:
- **Deployment**: Kaynak sınırları ile 2 replica
- **Service**: 80 portunda ClusterIP servisi
- **HPA**: Horizontal Pod Autoscaler (CPU bazlı 2-10 replica)
- **Güvenlik**: Root olmayan kullanıcı, güvenlik context'leri ve kaynak kısıtlamaları

## 🔄 CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/azure-kubernetes-service.yml`) şunları otomatikleştirir:

1. **Build**: Azure Container Registry ile container image oluşturma
2. **Push**: Image git SHA etiketi ile ACR'ye push edilir
3. **Deploy**: AKS cluster'a otomatik deployment

### GitHub Actions Kurulumu

GitHub repository'nizde aşağıdaki secret'ları yapılandırın:

- `AZURE_CLIENT_ID`: Service Principal client ID
- `AZURE_TENANT_ID`: Azure AD tenant ID  
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID

Workflow environment variable'larını güncelleyin:
```yaml
env:
  AZURE_CONTAINER_REGISTRY: "acr-adınız"
  CONTAINER_NAME: "contoso-air"
  RESOURCE_GROUP: "kaynak-grubunuz"
  CLUSTER_NAME: "aks-cluster-adınız"
```

## 🧹 Temizleme

İşiniz bittiğinde tüm Azure kaynaklarını kaldırın:

```bash
az group delete --name $AZURE_RESOURCE_GROUP_NAME --yes --no-wait
```

## 📊 Proje Durumu

Bu proje aktif olarak sürdürülmektedir ve aşağıdaki modernizasyon çalışmalarını temsil eder:
- **Azure DevOps Görevi**: #1892 - "Contoso Air Demo Uygulamasını Modernize Et"

### Tamamlanan İş Kalemleri
✅ Node.js 22 yükseltme ve bağımlılık modernizasyonu  
✅ Azure Managed Identity entegrasyonu  
✅ CosmosDB MongoDB API 7.0 geçişi  
✅ Kubernetes deployment manifest'leri  
✅ GitHub Actions CI/CD pipeline  
✅ Güvenlik sağlamlaştırması ile Docker konteynerizasyonu  
✅ Kapsamlı dokümantasyon  
✅ Prometheus monitoring entegrasyonu  
✅ Güvenlik en iyi uygulamalarının implementasyonu  

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır! Lütfen yönergeler için [CONTRIBUTING.md](CONTRIBUTING.md) dosyasına bakın.

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE.md](LICENSE.md) dosyasına bakın.

## 🔗 İlgili Kaynaklar

- [Orijinal ContosoAir Repository'si](https://github.com/microsoft/ContosoAir) (arşivlenmiş)
- [Azure CosmosDB Dokümantasyonu](https://docs.microsoft.com/tr-tr/azure/cosmos-db/)
- [Azure Managed Identity Dokümantasyonu](https://docs.microsoft.com/tr-tr/azure/active-directory/managed-identities-azure-resources/)
- [Azure Kubernetes Service Dokümantasyonu](https://docs.microsoft.com/tr-tr/azure/aks/)
- [Node.js En İyi Uygulamaları](https://github.com/goldbergyoni/nodebestpractices)

## 📧 Destek

Sorunlar ve sorular için:
- Bu repository'de bir issue açın
- Detaylı görev takibi için Azure DevOps projesine bakın
- Mevcut dokümantasyon ve kılavuzları kontrol edin

---

**Not**: Bu, öğrenme ve demo amaçlı bir demo uygulamasıdır. Production kullanımı için ek güvenlik sağlamlaştırması, monitoring ve test gerekli olacaktır.
