
# WSD Devops Interview

A brief description of what this project does and who it's for

#  Welcome to WSD DevOps Interview Challenge

---

##  Case & Scenarios

###  Ansible & Puppet

#### 1. Which Ansible command can display all `ansible_` configuration for a host?
```bash
ansible <host> -m setup -i inventory.yml
```
For example, for challenge number 3:
```bash
ansible app-vm -m setup -i inventory.yml
```

---

#### 2. Configure a cron job that runs `logrotate` every 10 minutes between 2h–4h on all machines.

The configuration is below there integrated with ansible yml and here is the reference yml 
```bash
*/10 2-4 * * * /usr/sbin/logrotate /etc/logrotate.conf
```

---

#### 3. Deploy the `ntpd` package to 3 servers with a custom `/etc/ntpd.conf` and configure Nagios monitoring.

**GitHub Reference:**  
[ Ansible Playbook – ntpd & Nagios Setup](https://github.com/safayetjamil647/wsd-devops-interview/tree/main/ansible)

**What This Playbook Does:**
- Installs `ntp`, `nagios-nrpe-server`, and `nagios-plugins`
- Replaces `/etc/ntp.conf` with a custom config
- Restarts the NTP service
- Adds NRPE checks (NTP & Ping) on all hosts
- Registers the machines to Nagios with templates:
  - `ntp-monitoring`
  - `ping-monitoring`

---

###  Docker / Kubernetes

#### 1. Prepare a `docker-compose.yml` for an Nginx server.

**Requirements Met:**
- Log persistence across restarts
- Custom bridge network with subnet `172.20.8.0/24`

 **GitHub Reference:**  
[ Nginx Docker Compose](https://github.com/safayetjamil647/wsd-devops-interview/tree/main/docker-kubernetes/nginx)

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./logs:/var/log/nginx
    networks:
      nginx_net:
        ipv4_address: 172.20.8.10

networks:
  nginx_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.8.0/24
          gateway: 172.20.8.1
```

---

#### 2. Which Kubernetes command shows the reason for a pod restart in the project `internal` under namespace `production`?
```bash
kubectl get pods -n production -l app=internal
```

---

#### 3. Java app keeps restarting — memory request 1000Mi, limit 1500Mi; CPU request 1000m, limit 2000m; Xmx = 1000M.

 **Possible Restart Causes:**
- **OOMKilled**: Java uses native memory beyond Xmx (e.g., metaspace, threads)
- **CPU Throttling**: App exceeds CPU limits
- **CrashLoop**: Logrotate failure or other startup issues
- **JVM Native Memory Leaks**

---

###  Helm

#### Elasticsearch deployment using Helm

 **GitHub Reference:**  
[ Elasticsearch Helm Chart](https://github.com/safayetjamil647/wsd-devops-interview/tree/main/elk-k8s)

 Deliverables:
- Final rendered `Deployment.yaml`
- Screenshot of Elasticsearch pod running![Elasticsearch Pod Running](./elk-k8s.png)
- Helm chart located in `elk-k8s/`

---

###  Metrics (Prometheus)

#### How Prometheus Works

1. **Scrapes metrics** from exporters like:
   - `node_exporter`, `blackbox_exporter`, etc.

2. **Stores metrics** in a time-series DB:
   - Multi-dimensional with labels for filtering/grouping

3. **Pull-based system**:
   - Host must expose metrics
   - Example: `node_exporter` runs on port `9100`

---

#### Custom Prometheus Alerts for Kubernetes

**Example 1: Node Not Ready**
```yaml
- alert: KubernetesNodeNotReady
  expr: kube_node_status_condition{condition="Ready",status="true"} == 0
  for: 10m
  labels:
    severity: critical
  annotations:
    summary: Kubernetes Node not ready (instance {{ $labels.instance }})
    description: "Node {{ $labels.node }} has been unready for a long time
  VALUE = {{ $value }}
  LABELS = {{ $labels }}"
```

 **Example 2: OOMKilled Detection**
```yaml
- alert: KubernetesContainerOomKiller
  expr: (kube_pod_container_status_restarts_total - kube_pod_container_status_restarts_total offset 10m >= 1)
    and ignoring (reason)
    min_over_time(kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}[10m]) == 1
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: Kubernetes Container oom killer (instance {{ $labels.instance }})
    description: "Container {{ $labels.container }} in pod {{ $labels.namespace }}/{{ $labels.pod }} has been OOMKilled {{ $value }} times in the last 10 minutes.
  VALUE = {{ $value }}
  LABELS = {{ $labels }}"
```

---

#### Prometheus Query in Grafana for Counter Metrics Trend

```prometheus
rate(http_requests_total[5m])
```

---

### Cassandra

#### Case: Query returns stale/deleted records.

**Likely Cause:**
- Cassandra uses **tombstones** for deletions
- Data only truly removed during **compaction**
- Inconsistent reads may serve stale data

**Fix:**
1. Set appropriate `gc_grace_seconds`
   ```sql
   ALTER TABLE keyspace.table_name WITH gc_grace_seconds = 86400;
   ```

2. Run frequent **repairs**:
   ```bash
   nodetool repair
   ```

3. Use strong **consistency levels**:
   - `QUORUM` or `ALL` for reads/writes

---

### MongoDB

#### Case: Shard `sanfrancisco.company_name` using `_id` key

**Assumptions:**
- Mongos connected
- Config servers healthy
- Sharding enabled

```javascript
sh.addShard("rs-shard-01/shard-01-node-a:27017,shard-01-node-b:27017,shard-01-node-c:27017");
sh.addShard("rs-shard-02/shard-02-node-a:27017,shard-02-node-b:27017,shard-02-node-c:27017");

sh.enableSharding("sanfrancisco");
sh.shardCollection("sanfrancisco.company_name", { _id: "hashed" });
```

---

For full source and configs: [🔗 GitHub Repo](https://github.com/safayetjamil647/wsd-devops-interview)
Notes : All of the above scenarios and cases solved by using previous experiences , official documentations of tools and components,blogs ,google and github example repositories 