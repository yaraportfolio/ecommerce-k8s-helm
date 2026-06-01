{{/*
Expand the name of the chart.
*/}}
{{- define "microservices.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "microservices.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "microservices.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "microservices.labels" -}}
helm.sh/chart: {{ include "microservices.chart" . }}
{{ include "microservices.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "microservices.selectorLabels" -}}
app.kubernetes.io/name: {{ include "microservices.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
==============================================
IMAGE REGISTRY HELPERS
==============================================
*/}}

{{/*
Génère l'URL complète de l'image selon le registryType
Usage: {{ include "microservices.image" (dict "root" . "service" .Values.services.AuthService) }}

Exemples:
  registryType: ghcr      → ghcr.io/yaraportfolio/auth-service:latest
  registryType: harbor    → harbor.myvbox.com/ecommerce/auth-service:v1.1
  registryType: dockerhub → yaramahi/auth-service:v1.1
*/}}
{{- define "microservices.image" -}}
{{- $root := .root }}
{{- $service := .service }}
{{- if eq $root.Values.image.registryType "ghcr" }}
{{- printf "%s/%s/%s:%s" $root.Values.image.ghcr.registry $root.Values.image.ghcr.owner $service.name $service.image.tag }}
{{- else if eq $root.Values.image.registryType "harbor" }}
{{- printf "%s/%s/%s:%s" $root.Values.image.harbor.registry $root.Values.image.harbor.project $service.name $service.image.tag }}
{{- else if eq $root.Values.image.registryType "dockerhub" }}
{{- printf "%s/%s:%s" $root.Values.image.dockerhub.username $service.name $service.image.tag }}
{{- else }}
{{- printf "%s/%s:%s" $root.Values.image.dockerhub.username $service.name $service.image.tag }}
{{- end }}
{{- end }}

{{/*
Vérifie si des imagePullSecrets sont nécessaires
Harbor → TOUJOURS true (obligatoire)
Docker Hub → Selon configuration utilisateur

Retourne: "true" ou "false" (string)
*/}}
{{- define "microservices.needsImagePullSecrets" -}}
{{- if eq .Values.image.registryType "harbor" }}
{{- "true" }}
{{- else }}
{{- .Values.image.imagePullSecrets.enabled | toString }}
{{- end }}
{{- end }}

{{/*
Retourne la liste des imagePullSecrets selon le registryType
Usage: {{- include "microservices.imagePullSecrets" . | nindent 8 }}

⚠️ IMPORTANT : Harbor EXIGE TOUJOURS des credentials
*/}}
{{- define "microservices.imagePullSecrets" -}}
{{- if eq (include "microservices.needsImagePullSecrets" .) "true" }}
{{- if eq .Values.image.registryType "harbor" }}
- name: harbor-registry
{{- else if eq .Values.image.registryType "dockerhub" }}
- name: dockerhub-registry
{{- end }}
{{- end }}
{{- end }}
