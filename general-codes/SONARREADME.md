Get list of the Quality Gates:
```bash
$ curl -s -u admin:admin http://localhost:9000/api/qualitygates/list | jq
```

Get Quality Gate with ID number '2':
```bash
$ curl -s -u admin:admin http://localhost:9000/api/qualitygates/show?id=2 | jq
{
  "id": 2,
  "name": "fqmGate"
}
```

Create new Quality Gate with name "FluxGate":
```bash
$ curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create?name=FluxGate"
{"id":3,"name":"FluxGate"}
```

Create new Condition for the Metric with name 'fqm_hardwarerequirementslinkedtofluxarchitecturaldesign' in API:
```bash
$ curl -s -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=3&metric=fqm_hardwarerequirementslinkedtofluxarchitecturaldesign&op=GT&warning=0&error=5" | jq
{
  "id": 7,
  "metric": "fqm_hardwarerequirementslinkedtofluxarchitecturaldesign",
  "op": "GT",
  "warning": "0",
  "error": "5"
}
```

Search Sonarqube API for domain name in metrics:
```bash
$ curl -s -u admin:admin -X POST "http://localhost:9000/api/metrics/search?f=domain" | jq '.' | grep fqm
      "key": "fqm_hardwarecomponents",
      "key": "fqm_hardwarecomponentswithlinkedrequirements",
      "key": "fqm_hardwarerequirements",
      "key": "fqm_hardwarerequirementslinkedtofluxarchitecturaldesign",
      "key": "fqm_modelerrors",
      "key": "fqm_modelwarnings",
```

Search in API for our plugin keys: 
```bash
$ curl -s -u admin:admin -X POST "http://localhost:9000/api/metrics/search" | jq '.metrics | .[].key' | grep 'fqm_' | tr -d '"'
fqm_hardwarecomponents
fqm_hardwarecomponentswithlinkedrequirements
fqm_hardwarerequirements
fqm_hardwarerequirementslinkedtofluxarchitecturaldesign
fqm_modelerrors
fqm_modelwarnings
```

Get list of all domains:
```bash
$ curl -s -u admin:admin -X POST "http://localhost:9000/api/metrics/domains" | jq '.'
{
  "domains": [
    "Size",
    "Management",
    "C++",
    "Duplications",
    "Security",
    "Coverage",
    "General",
    "Flux Quality Metrics",
    "Releasability",
    "Documentation",
    "Issues",
    "SCM",
    "Complexity",
    "Maintainability",
    "Reliability"
  ]
}
```
