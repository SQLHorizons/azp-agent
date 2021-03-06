lint:
	helm lint charts/azp-agent

template:
	helm template charts/azp-agent --values example-helm-values.yaml

template-default-values:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl

template-docker-tls-disabled:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,docker.tls=false

template-no-persistence:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.persistence.enabled=false,docker.persistence.enabled=false

template-no-docker:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,docker.enabled=false

template-persistence:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.persistence.enabled=true,docker.persistence.enabled=true

template-combined-volume:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.persistence.enabled=true,docker.persistence.enabled=true,docker.persistence.name=workspace

template-docker-no-clean:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.persistence.enabled=true,docker.persistence.enabled=true,docker.clean=false

template-docker-lifecycle:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.persistence.enabled=true,docker.persistence.enabled=true,docker.clean=true,docker.lifecycle.preStop .tcpSocket.port=1337

template-docker-lifecycle-fail:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.persistence.enabled=true,docker.persistence.enabled=true,docker.clean=true,docker.lifecycle.preStop.exec.command={sh,-c,ls}

template-env-secret:
	helm template charts/azp-agent --set 'azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.extraEnv[0].name=SUPER_SECRET_PASSWORD,azp.extraEnv[0].value=P@$$W0RD,azp.extraEnv[0].secret=true'

template-autoscaler:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,scaling.enabled=true,scaling.serviceMonitor.enabled=true,scaling.pdb.enabled=true,scaling.grafanaDashboard.enabled=true

template-hpa:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,scaling.enabled=true,scaling.cpu=50%

template-existing-secret:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,scaling.enabled=true,azp.existingSecret=test-secret,azp.existingSecretKey=test-secret-key

template-vsts:
	helm template charts/azp-agent --set azp.url=https://dev.azure.com/test,azp.token=abc123def456ghi789jkl,azp.image.repository=microsoft/vsts-agent,azp.image.tag=ubuntu-16.04-docker-18.06.1-ce-standard,azp.useStartupScript=true

test:
	make lint && \
	make template && \
	make template-default-values && \
	make template-docker-tls-disabled && \
	make template-no-persistence && \
	make template-no-docker && \
	make template-persistence && \
	make template-combined-volume && \
	make template-docker-no-clean && \
	make template-docker-lifecycle && \
	! make template-docker-lifecycle-fail && \
	make template-env-secret && \
	make template-autoscaler && \
	make template-hpa && \
	make template-existing-secret && \
	make template-vsts

test-versions:
	bash -c 'for chart in charts/*.tgz; do helm lint $$chart; done'

install:
	helm upgrade --debug --install azp-agent charts/azp-agent --values example-helm-values.yaml --set azp.url=${AZURE_DEVOPS_URL},azp.token=${AZURE_DEVOPS_TOKEN},azp.pool=${AZURE_DEVOPS_POOl},azp.persistence.enabled=false,docker.persistence.enabled=false,replicaCount=1,scaling.logLevel=trace

package:
	helm package charts/azp-agent -d charts && \
	helm repo index --merge charts/index.yaml charts
