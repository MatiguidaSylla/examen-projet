# examen-projet-M2RSI Prof Massa
# 📊 Projet Multicloud provider  Monitoring(Grafana,Prometheus) Automatisation  avec Terraform, Ansible.

Ce projet met en place automatiquement une **infrastructure complète de monitoring** dans le cloud (AWS), permettant de :
- Créer une instance EC2 Ubuntu via **Terraform**
- Configurer automatiquement **Docker**, **Prometheus** et **Grafana** via **Ansible**
- Gérer le tout de manière **automatisée via GitHub Actions (CI/CD)**

> 💡 Objectif : Obtenir en une seule commande (ou push Git) un serveur de monitoring prêt à l’emploi.

---

## 🧱 Objectifs pédagogiques

Ce projet est idéal pour :

- Apprendre **l'infrastructure as code (IaC)** avec Terraform
- Maîtriser **l'automatisation de la configuration** avec Ansible
- Comprendre le déploiement d'une **stack de monitoring moderne**
- S’initier à la **CI/CD avec GitHub Actions**
- Sécuriser un déploiement cloud avec des clés SSH & secrets GitHub

---

## 🗂️ Structure du projet


.
├── terraform/              # Fichiers d’infrastructure AWS
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── ansible/                # Configuration du serveur EC2
│   ├── playbook.yml
│   ├── hosts               # Généré automatiquement avec l’IP EC2
│   ├── templates/
│   │   ├── prometheus.yml.j2
│   │   └── grafana-dashboard.json.j2
├── .github/workflows/      # Déploiement CI/CD
│   └── deploy.yml
├── README.md

🔐 Prérequis et sécurité
1. Clé SSH
Génère une clé SSH pour te connecter à l’instance EC2 :




ssh-keygen -t rsa -b 4096 -f ~/.ssh/monitoring_key
Ajoute la clé publique .pub à AWS (dans la console EC2 > Key Pairs), et copie le contenu de la clé privée dans GitHub Secrets.

2. Secrets GitHub (CI/CD)
Va dans Settings > Secrets and variables > Actions de ton repo GitHub, ajoute :

Nom du secret	Description
AWS_ACCESS_KEY_ID	Clé IAM pour Terraform
AWS_SECRET_ACCESS_KEY	Clé IAM secrète
SSH_PRIVATE_KEY	Contenu texte de la clé .pem SSH

🛠️ Déploiement manuel (optionnel)
Si tu veux tester localement sans GitHub Actions :




cd terraform
terraform init
terraform apply -auto-approve

# Ensuite
cd ../ansible
ansible-playbook -i hosts playbook.yml
🚀 Déploiement automatique (CI/CD)
Tout est automatisé avec GitHub Actions. Sur chaque git push main :

Terraform est lancé pour créer l'infra

L’IP publique de l’instance EC2 est récupérée

Ansible est exécuté pour configurer l’instance (Prometheus, Grafana, Docker…)

yaml


# .github/workflows/deploy.yml (extrait)
- name: Setup private SSH key
  run: |
    mkdir -p ansible
    echo "${{ secrets.SSH_PRIVATE_KEY }}" > ansible/key.pem
    chmod 400 ansible/key.pem
📊 Résultat final
✅ Serveur EC2 avec Ubuntu + Docker

✅ Conteneurs Prometheus et Grafana actifs

✅ Dashboard Grafana préconfiguré avec des métriques système

✅ Accessible via :

Service	URL
Grafana	http://<IP>:3000 (admin/admin)
Prometheus	http://<IP>:9090

✍️ Extrait du playbook Ansible
yaml


- name: Setup Docker, Prometheus and Grafana
  hosts: monitoring
  become: true

  tasks:
    - name: Install Docker
      apt:
        name: docker.io
        state: present
        update_cache: yes

    - name: Start Prometheus
      docker_container:
        name: prometheus
        image: prom/prometheus
        ports:
          - "9090:9090"
        volumes:
          - ./prometheus.yml:/etc/prometheus/prometheus.yml
🧼 Nettoyage
Pour détruire l’infrastructure proprement :




cd terraform
terraform destroy -auto-approve
❗ Conseils importants
N’ouvre pas les ports en production sur 0.0.0.0/0 (ici c’est fait pour test/démo)
Ne versionne jamais ta clé .pem (elle est gérée en secret GitHub)

Vérifie que ta région AWS dans terraform.tfvars correspond à ta Key Pair

Teste ton accès SSH manuellement si Ansible échoue

✅ À faire ensuite
Ajouter Node Exporter pour surveiller davantage de métriques

Ajouter Alertmanager (notifications)

Ajouter un domaine personnalisé (via Route 53 ou autre)

Monitorer d'autres serveurs depuis Prometheus

📄 Licence
Ce projet est sous licence MIT — libre d’usage, modification et distribution.
Matiguida Sylla Dakar
