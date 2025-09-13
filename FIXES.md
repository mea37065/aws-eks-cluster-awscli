# Opravy chýb v aws-eks-cluster-awscli

## Kritické opravy

### 1. PodSecurityPolicy (CRITICAL)
- **Problém**: Používa deprecated `policy/v1beta1` API, odstránené v Kubernetes 1.25+
- **Oprava**: Pridané varovanie o deprecated API a odporúčanie na migráciu na Pod Security Standards

### 2. Security scan workflow (HIGH)
- **Problém**: `exit-code: '0'` maskuje security vulnerabilities
- **Oprava**: Zmenené na `exit-code: '1'` aby workflow zlyhal pri nájdení vulnerabilities

### 3. Metrics Server sťahovanie (HIGH)
- **Problém**: Sťahovanie z `latest` URL bez verifikácie
- **Oprava**: Používa konkrétnu verziu (v0.6.4) s error handling

### 4. CloudFormation error handling (HIGH)
- **Problém**: Chýbajúca validácia stack existencie a výstupov
- **Oprava**: Pridané kontroly existencie stacku a validácia všetkých výstupov

### 5. Subnet parsing validácia (HIGH)
- **Problém**: Predpokladá presne 3 subnety bez validácie
- **Oprava**: Pridané kontroly či sú všetky subnet premenné neprázdne

## Stredné opravy

### 6. Cluster Autoscaler konfigurácia (MEDIUM)
- **Problém**: Hardcoded cluster name "eks-demo"
- **Oprava**: Používa placeholder CLUSTER_NAME, dynamicky nahradený v install-addons.sh

### 7. Ingress deprecated annotation (MEDIUM)
- **Problém**: `kubernetes.io/ingress.class: alb` je deprecated
- **Oprava**: Nahradené moderným `spec.ingressClassName: alb`

### 8. ImagePullPolicy optimalizácia (MEDIUM)
- **Problém**: `imagePullPolicy: "Always"` spôsobuje zbytočné sťahovanie
- **Oprava**: Zmenené na `"IfNotPresent"` pre lepšiu performance

### 9. Network Policy namespace selector (MEDIUM)
- **Problém**: Používa `name: default` label ktorý nemusí existovať
- **Oprava**: Používa štandardný `kubernetes.io/metadata.name: default`

### 10. Terraform cluster endpoint (MEDIUM)
- **Problém**: Cluster endpoint nie je označený ako sensitive
- **Oprava**: Pridaný `sensitive = true` flag

## Menšie opravy

### 11. Shell scripting (LOW)
- **Problém**: Nepoužívané premenné (RED), chýbajúce úvodzovky
- **Oprava**: Odstránené nepoužívané premenné, pridané úvodzovky okolo premenných

### 12. Parameter expansion (LOW)
- **Problém**: Používa `sed` pre jednoduché string replacement
- **Oprava**: Používa bash parameter expansion `${var#prefix}`

### 13. Monitoring hardcoded heslo (HIGH)
- **Problém**: Hardcoded heslo "admin123" v plain texte
- **Oprava**: Inštrukcie na získanie hesla z Kubernetes secret

### 14. CloudFormation template validácia (MEDIUM)
- **Problém**: Chýbajúca kontrola existencie template súboru
- **Oprava**: Pridaná kontrola `[[ -f "$CFN_TEMPLATE" ]]`

## Odporúčania pre ďalšie zlepšenia

1. **Migrácia z PodSecurityPolicy**: Implementovať Pod Security Standards
2. **Multi-region podpora**: Rozšíriť AzMap mapping pre viac regiónov
3. **NAT Gateway HA**: Zvážiť použitie NAT Gateway v každej AZ pre vysokú dostupnosť
4. **Secrets management**: Implementovať AWS Secrets Manager pre citlivé údaje
5. **Monitoring alerting**: Pridať AlertManager konfiguráciu
6. **Backup stratégia**: Implementovať Velero pre cluster backups

## Testovanie

Po implementácii opráv odporúčame:

1. Spustiť `make lint` pre kontrolu syntaxe
2. Otestovať deployment v test prostredí
3. Overiť funkčnosť všetkých komponentov pomocou `make test`
4. Skontrolovať security scan výsledky v GitHub Actions