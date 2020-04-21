# BigDataProject
A guide to create a cluster of AWS EC2 Instances configured with Apache Hadoop and Apache Spark. AWS Organization is also explained to create a cluster of instances shared by multiple accounts. Terraform configuration is also described with the use of some bash scripts to automate the creation of the instances of the cluster and their configuration.

_______CREAZIONE DI UNA ORGANIZZAZIONE, VPC E SUBNET PRIVATE, CONDIVISIONE DELLA SUBNET_______




La creazione di un organizzazione parte dalla guida al link https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_create.html 
Qui AWS spiega le modalità con cui creare l'organizzazione:

1. Accedere al link https://console.aws.amazon.com/organizations/ (AWS consiglia di accedere come IAM user, quindi con un ruolo IAM, e non
raccomanda l'accesso come root user, in questo modo il "master" dell'organizzazione può gestire gli accessi alle risorse e proteggere le proprie
dato che da root user l'accesso alle risorse è illimitato. AWS spiega come creare un ruolo e un gruppo IAM al seguente link
https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html ma questa guida non lo descriverà.
Inoltre al link https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html sono spiegate le best practices per IAM)

2. Nella pagina di introduzione, cliccare su "Create organization" e poi "Create organization" nella schermata di conferma (la stellina indica l'account master)

3. Verifica l'indirizzo email che si trova nella propria casella postale entro 24 ore

Ora si possono invitare gli account (potrebbe essere necessario aspettare ore o anche un giorno prima che l'organizzazione sia stata completamente inizializzata
altrimenti contattare AWS Support). Per invitare:
1. Cliccare su "Add account" all'interno del tab "Accounts"
2. Scegliere "Invite Account"
3. Inserire l'indirizzo email o l'ID dell'account AWS. Per inserire più account separarli con una virgola
4. (inserire Note opzionali) Cliccare "Invite"

# Abilitazione condivisione risorse

- Ora bisogna abilitare la condivisione delle risorse nell'organizzazione, effettuabile al link https://console.aws.amazon.com/ram/home?region=us-east-1#Settings
(nel caso siate nella regione "us-east-1"), spuntare la casella su "Enable sharing within your AWS Organization" e confermare con "Save settings"

# Creazione VPC

Selezionare la voce "VPC" all'interno del gruppo "Reti E Distribuzione Di Contenuti", accessibile dal menù "Servizi" in console e:
1.  Cliccare su Launch VPC Wizard e cliccare su Select, il quale apparirà nella pagine dello wizard
2.  A questo punto bisogna assegnare un nome alla VPC in "VPC name" e confermare con "Create VPC"

3. Ora dal menù a sinistra selezionate la voce "Subnets" e potrete notare una subnet chiamata "Public subnet" con il gruppo di indirizzi mostrato nello wizard
   (ex. 10.0.0.0/24)
4. Cambiate il nome della subnet e scegliete uno a piacimento, ma non lasciare "Public subnet", altrimenti potreste confonderle con altre subnet create dallo wizard
5. Selezionare la subnet appena creata e cliccate su "Actions" (o clic destro del mouse sulla subnet) e selzionare la voce "Modify auto-assign IP settings"
6. Nella schermata che appare spuntare la casella "Auto-assign IPv4" in modo che AWS assegni gli IPv4 pubblici alle istanze e sia possibile accedervi tramite SSH
   e cliccare su "Save" per confermare

A questo punto abbiamo la nostra subnet dentro cui possiamo creare le nostre istanze ed essere certi che esse possano comunicare direttamente tramite IPv4 privati.

# Creazione di una condivisione di risorsa

Dal menù "Servizi" selezionare "Resource Access Manager" all'interno del gruppo "Sicurezza, Identità, Conformità".
Una volta fatto eseguire i seguenti passaggi per condividere la subnet con i membri della propria organizzazione:
1. Cliccare su "Create a resource share" nella pagina di "Resource Access Manager" (RAM)
2. Scegliere un nome per la risorsa (nel nostro caso stiamo condividendo una subnet, quindi magari un nome che la identifichi)
3. Dal menù "Select resource type" scegliere la voce "Subnets", dovrebbe comparire la subnet col nome scelto durante la sua crezione fatta in precedenza.
4. Dalla sezione "Shared principals" cliccare su "Show organization structure" e scegliere l'intera organizzazione ("Allow external accounts" deve essere spuntato)
5. Selezionarla e confermare il tutto con "Create resource share".
6. Adesso tornerete alla home di RAM in cui AWS vi conferma la creazione della condivisione di risorsa avvisando che potrebbe volerci
   qualche minuto prima che sia disponibile.


# Preparazione alla creazione delle istanze

Dal menù "Servizi" selezioniamo "EC2" nel gruppo "Calcolo":
- Selezioniamo la voce "Instances" dal menù a sinistra e clicchiamo il pulsante "Launch Instance", a questo punto inizia la parte successiva




_________CREAZIONE DI DUE ISTANZE AWS CON HADOOP 3.1.3 E SPARK 2.4.4__________




Una volta cliccato il pulsante "Launch Instance" bisogna:

1. Selezionare l'AMI (Amazon Machine Image) col tasto "Select" alla destra dell'AMI, per questa guida è stato usato Ubuntu 18.04 a 64-bit.
	NOTA: Una volta creato un proprio AMI sarà accessibile alla voce "My AMIs" nel menù a sinistra
2. Selezionare il tipo di instanza, l'unica valida per il Free tier è la t2.micro, nel nostro test abbiamo usato l'r5.large, ma la guida per configurarle è identica
3. Cliccare su "Next: Configure Instance Details"
4. Lasciare a 1 la voce "Number of instances", le altre istanze verranno create tramite l'AMI di quella che creeremo
5. Alla voce "Network" scegliere la VPC creata in precedenza, dove si potrà notare il nome scelto
6. La subnet verrà automaticamente selezionata da AWS
7. Cliccare su "Next: Add Storage" per continuare
8. Qui potete scegliere lo storage della macchina, potete scegliere anche 30 GiB perché AWS vi charga solo se occupate con i dati effettivamente più di 30 GB
9. Cliccare su "Next: Add Tags" e su "Next: Configure Security Group"
10. Lasciate l'opzione "Create a new security group" e date un nuovo nome nel campo "Security group name" (ex. hadoop)
11. Cliccare su "Review and Launch" e poi "Launch" nella schermata successiva (Ignorate gli avvisi di sicurezza di Amazon)
12. Adesso vi compare una finestra di dialogo dove dovreste avere selezionata la voce "Create a new key pair" e data un nuovo nome in "Key pair name",
    poi cliccate su "Download Key Pair" che scaricherà la chiave privata con estensione ".pem" che vi permetterà di accedere alle istanze via SSH.
    Cliccate "Launch Instances" per confermare.

# Settaggio nome nuova istanza

Ora le istanze sono state create e bisogna tornare nela sezione "Instances", qui vedremo la nostra istanza senza nome, quindi clccate sulla matita che appare
quando vi avvicinate allo spazio vuoto sotto la colonna "Name" e inserite "namenode" come nome, questo sarà il master del nostro cluster

NOTA: le istanze possono essere stoppate e startate selezionandole e cliccando su "Actions -> Instance State -> Stop". Il comando "Terminate" elimina permanentemente l'istanza.

# Modifica Security Group

Dal menù a sinistra andate in basso fino al gruppo "NETWORK & SECURITY" e selezionate la voce "Security Groups":
1. Selezionare la casella a fianco al security group col nome che è stato scelto durante la creazione dell'istanza
   Dovrebbe apparire un menù sotto coi tabs "Details \ Inbound rules \ Outbound rules \ Tags"
2. Selezionare "Inbound rules" e cliccare sul tasto "Edit inbound rules" che compare
3. Compare una schermata dove bisogna cliccare "Add rule"
4. Scegliere "All traffic" come Type e in Source selezionare "Custom" e scrivere il CIDR scelto per la subnet (es. 10.0.0.0/24)
5. In basso cliccate su "Save rules"

# Ulteriori concetti sulla condivisione dell'AMI e delle key pairs

Adesso avete la chiave privata per accedere tramite SSH alle istanze con un estensione ".pem".
Nel caso in cui vogliate che gli altri utenti dell'organizzazione utilizzino la stessa chiave per le loro macchine dovete inviare loro la chiave privata.
A questo punto è necessario generare la chiave pubblica che dovrà essere importata su AWS affinché altre nuove istanze utilizzino questa stessa chiave.
La stessa chiave pubblica si può ricavare dalla istanza EC2 appena creata oppure generandola col comando:

- ssh-keygen -y -f key.pem > key.pub     (su Linux shell o Windows Powershell con Client OpenSSH installato)

Questo comando genera tramite una chiave privata (nell'esempio "key.pem") per generare una chiave pubblica (nell'esempio "key.pub")

Per importare la chiave pubblica appena creata bisogna selezionare la voce "Key Pairs" nel gruppo "Network & Security" che si trova nel menù a sinistra della console.
A questo punto cliccare sul tasto "Actions" che dovrebbe aprire un menù a tendina da cui bisogna selezionare "Import key pair":

1. Scegliere un nome per la "key pair" e selezionarla dal file system tramite il tasto "Browse".
2. Una volta importata si dovrebbe vedere che AWS l'ha riconosciuta con una spunta verde, a questo punto confermare con "Import key pair".

Per condividere un'AMI privata con altri utenti selezionare "AMIs" nel gruppo "IMAGES" dal menù a sinistra della EC2 console.
Selezionare l'AMI e cliccare su "Actions" e scegliere l'opzione "Modify Image Permissions", aggiungere l'AWS Account Number dell'utente con cui condividere l'AMI
e cliccare su "Add Permission"; infine confermare con "Save".


# Connettersi alle istanze


NOTA: Si può fare anche su Windows, basta installare ssh: andare in APP E FUNZIONALITÀ -> GESTISCI FUNZIONALITÀ FACOLTATIVE ->
-> Aggiungi una funzionalità e installare "Client OpenSSH"

Connettersi all'istanza col comando:
- ssh -i key.pem ubuntu@PUBLIC_DNS_ADDRESS  (ex: ssh -i "bigdata.pem" ubuntu@ec2-34-227-83-101.compute-1.amazonaws.com)
Creare un'altra shell e inviare la chiave scaricata da AWS col comando: 
- scp -i 'key.pem' key.pem ubuntu@PUBLIC_DNS_ADDRESS:/home/ubuntu/.ssh
Chiudere quest'ultima shell e tornare sulla precedente.
Impostare sicurezza sulla chiave:
- chmod 400 /home/ubuntu/.ssh/key.pem

# Modifica Hostnames (ATTENZIONE ## namenode e datanode1 coincidono con namenode in AWS)

- sudo nano /etc/hosts
Scrivere dentro:

PRIVATE_IP_NAMENODE namenode
PRIVATE_IP_NAMENODE datanode1

# Configurare SSH
- nano /home/ubuntu/.ssh/config
E scrivere dentro:

Host namenode
HostName namenode
User ubuntu
IdentityFile /home/ubuntu/.ssh/my-key.pem
Host datanode1
HostName namenode
User ubuntu
IdentityFile /home/ubuntu/.ssh/my-key.pem


# Aggiornare i package nella macchina e installare Java:
- sudo apt-get update && sudo apt-get dist-upgrade
- sudo apt-get install openjdk-8-jdk
- wget http://mirror.nohup.it/apache/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz
- tar -xvzf ./hadoop-3.1.3.tar.gz
- sudo mv ./hadoop-3.1.3 /home/ubuntu/hadoop
- rm hadoop-3.1.3.tar.gz

# Modificare le variabili d'ambiente
- sudo nano /etc/environment

E scrivere dentro:

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/ubuntu/hadoop/bin:/home/ubuntu/hadoop/sbin"
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"

- source /etc/environment

- nano /home/ubuntu/.profile

E scrivere dentro:

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
export HADOOP_HOME=/home/ubuntu/hadoop
export HADOOP_CONF_DIF=/home/ubuntu/hadoop/etc/hadoop

- source /home/ubuntu/.profile

# Setup Hadoop
Nelle linee di codice successive il tag <configuration> è presente per far capire dove scrivere i valori,
ma non va riscritto perché è già presente nei file.

- nano $HADOOP_CONF_DIF/hdfs-site.xml
E scrivere dentro:

<configuration>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/home/ubuntu/hadoop/data/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/home/ubuntu/hadoop/data/datanode</value>
  </property>
  <property>
    <name>dfs.replication</name>
    <value>2</value>
  </property>
</configuration>

- nano $HADOOP_CONF_DIF/core-site.xml
E scrivere dentro:

<configuration>
  <property>
    <name>fs.default.name</name>
    <value>hdfs://namenode:9000</value>
  </property>
</configuration>

- nano $HADOOP_CONF_DIF/yarn-site.xml
E scrivere dentro:

<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
      <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
      <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>namenode</value>
  </property>
  <property>
    <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
  </property>
</configuration>

- nano $HADOOP_CONF_DIF/mapred-site.xml
E scrivere dentro:

<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
    </property>
</configuration>

- nano $HADOOP_CONF_DIF/masters
Scrivere dentro:

namenode

- nano $HADOOP_CONF_DIF/workers
IMPORTANTE: cancellare localhost (dato che datanode1 conterrà lo stesso valore, localhost e datanode1 insieme NO, uno dei due)
Scrivere dentro:

datanode1

w
IMPORTANTE: Affinché Hadoop funzioni correttamente la sua configurazione dev'essere identica per tutti i nodi, quindi anche i nodi dentro
il file "workers" soprastante deve essere identico per ogni macchina.

# Configurare Spark
- wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
- tar -xvzf spark-2.4.4-bin-hadoop2.7.tgz
- sudo mv ./spark-2.4.4-bin-hadoop2.7 /home/ubuntu/spark
- rm spark-2.4.4-bin-hadoop2.7.tgz
- sudo cp spark/conf/spark-env.sh.template spark/conf/spark-env.sh
- sudo nano spark/conf/spark-env.sh
Scrivere dentro:

export SPARK_MASTER_HOST=namenode
export HADOOP_CONF_DIR="/home/ubuntu/hadoop/etc/hadoop"
export PYSPARK_PYTHON="/usr/bin/python3"

Creare il file "slaves" per avviare tutti gli slaves con unico comando:

- nano spark/conf/slaves
Scrivere dentro:

datanode1


A questo punto la guida si divide in 2:
1) Creazione del cluster manualmente, ovvero creando le altre istanze con l'AMI della prima (o copia manuale) e aggiornando tutti i file di configurazione
   per ogni istanza aggiunta al cluster
2) Configurazione di Terraform, in modo tale da creare un numero di istanze a piacimento in maniera automatica e creando degli script che aggiornino
   automaticamente i file di configurazione con i dati delle istanze generate da Terraform

I numerosi dash ('-', "trattini") comprendono queste due possibilità, la restante parte di guida spiega l'avvio di Hadoop, di Spark e l'esecuzione
di un codice tramite spark nel cluster.


# Copia AMI (SE VOLETE FARE QUESTO CREERÀ UNO SNAPSHOT CHE SE SUPERA 1GB AVRÀ UN COSTO,
		MA VELOCIZZA IL PROCESSO FACENDO UN'ALTRA ISTANZA SULLA COPIA DEL PRIMO,
		PER EVITARLO CREARE MANUALMENTE UN'ALTRA ISTANZA E FARE TUTTI I PASSAGGI PRECEDENTI)

Andare su EC2 Instances su AWS Console e cliccare il tasto destro sull'istanza -> Image -> Create Image
Scegliere un nome per l'immagine a piacimento e confermare cliccando "Create Image"

---------------------------------------------------------------------------------------------------------------------------------------------------------------

1)
# Creazione di una singola istanza con l'immagine manualmente

Andate in Images e cliccare Launch selezionando l'immagine appena creata
Impostate stessi settaggi
IN PARTICOLARE SCEGLIERE LO STESSO SECURITY GROUP
Ovvero selezionare "Select an existing security group" e scegliere quello creato in precedenza
Scegliere la stessa Key Pair

NOME NUOVA ISTANZA SU EC2: 'datanode2'

SEMPRE SUL MASTER
| | | | | | | | | | | |
v v v v v v v v v v v v

A questo punto bisogna aggiornare il file /etc/hosts su entrambe le macchine,
ma per adesso modificheremo solo i file di namenode, poi si capirà il motivo.
Quindi eseguire il comando:

- sudo nano /etc/hosts
Aggiungere dentro:

PRIVATE_IP_DATANODE2 datanode2

(ATTENZIONE ## namenode e datanode1 coincidono con namenode in AWS, datanode2 coincide con datanode2 in AWS)

Successivamente modificare la configurazione SSH:
- nano /home/ubuntu/.ssh/config
E aggiungere dentro:

Host datanode2
HostName datanode2
User ubuntu
IdentityFile /home/ubuntu/.ssh/my-key.pem

Poi modificare i workers di hadoop:
- nano $HADOOP_CONF_DIF/workers
E aggiungere dentro:

datanode2

Infine SOLO SUL MASTER aggiungere datanode2:
- nano spark/conf/slaves
E aggiungere dentro:

datanode2


Per testare il funzionamento  di SSH (chiudere ogni connessione con CTRL-D dopo esservi connessi):
- ssh datanode1 (si connette all'host stesso, quindi namenode)
- ssh datanode2 (si connette all'istanza "datanode2")

Adesso aggiorneremo gli stessi file su datanode2 ma eseguiremo i comandi sempre dal master
NOTA: l'istanza datanode2 dev'essere accesa.

Aggiornare /etc/hosts su datanode2
- cat /etc/hosts | ssh datanode2 "sudo sh -c 'cat >/etc/hosts'"

Aggiornare SSH config su datanode2
- cat /home/ubuntu/.ssh/config | ssh datanode2 "sudo sh -c 'cat >/home/ubuntu/.ssh/config'"

Aggiornare hadoop workers su datanode2
- cat /home/ubuntu/hadoop/etc/hadoop/workers | ssh datanode2 "sudo sh -c 'cat >/home/ubuntu/hadoop/etc/hadoop/workers'"



2)
# Configurazione di Terraform

Scaricare Terraform copiando il link per la versione Linux (nel nostro caso a 64bit) che si può trovare al link
https://www.terraform.io/downloads.html eseguendo il comando:

- wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip

ATTENZIONE: questo è il link usato nella guida, prendere il più recente fornito da Terraform.

L'eseguibile terraform è contenuto all'interno dello zip che si può unzippare con la libreria "unzip".
Se non presente sarà necessario scaricarla col comando:

- sudo apt install unzip

A questo punto unzippiamo l'archivio e rimuoviamolo coi comandi:
- unzip terraform_0.12.24_linux_amd64.zip
- rm terraform_0.12.24_linux_amd64.zip

Nella cartella corrente avremo un file eseguibile "terraform", creiamo una cartella e spostiamolo lì:
- mkdir Terraform
- mv terraform Terraform/

Aggiungiamo alle variabili d'ambiente anche terraform. Eseguire i passaggi:
1. eseguire il comando:
- sudo nano /etc/environment
2. Aggiungere alla fine della stringa PATH il valore:
- :/home/ubuntu/Terraform       (i : due punti sono necessari per dividere due path tra loro)
3. Dopo aver salvato eseguire:
- source /etc/environment

A questo punto possiamo usare terraform in qualsiasi cartella, basterà eseguire:
- terraform
E vedremo l'output che ci mostra tutti i comandi.

Creiamo il file di configurazione per terraform:
- nano Terraform/main.tf

E scrivere dentro:


provider "aws" {
  profile = "default"
  region = "REGION"
}

resource "aws_instance" "testInstances" {
   ami = "AMI_ID"
   instance_type = "INSTANCE_TYPE"
   subnet_id = "SUBNET_ID"
   vpc_security_group_ids = [
      "SECURITY_GROUP_ID",
   ]
   count = NUM_INSTANCES
}


I nomi in maiuscolo sono da sostituire con i valori della vostra configurazione. count è il numero di istanze da creare.
Un file main.tf d'esempio può essere:

provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_instance" "testInstances" {
   ami = "ami-01926394e20264954"
   instance_type = "r5.large"
   subnet_id = "subnet-00fbaf25f9b79f847"
   vpc_security_group_ids = [
      "sg-0980d39f95d96a1b1",
   ]
   count = 2
}


Salvare il file.

# Installazione di AWS CLI e creazione delle chiavi di accesso

A questo punto è necessario installare l'AWS CLI affinché terraform possa accedere e utilizzare le nostre risorse.
La guida per installare l'AWS CLI si trova al link https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
In questa guida installeremo l'AWS CLI version 2 con i comandi:
- curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
- unzip awscliv2.zip
- sudo ./aws/install
- rm awscliv2.zip

Adesso che abbiamo installato AWS CLI dobbiamo tornare sulla AWS console. Eseguire i seguenti passaggi:
1. Aprire il menù dropdown cliccando il proprio nome nella barra in cima alla console
2. Selezionare "Le mie credenziali di sicurezza"
3. Aprire il tab "Chiavi di accesso" e selezionare "Crea nuova chiave di accesso"
4. Si aprirà una finestra di dialogo da cui si potranno scaricare le chiavi cliccando "Scarica file di chiavi".

Tornare sulla shell del master namenode ed eseguire il comando:
- aws configure

E inserire i dati uno per uno come in questo esempio:

AWS Access Key ID [None]: PRESENTE NEL CSV SCARICATO COME AWSAccessKeyId
AWS Secret Access Key [None]: PRESENTE NEL CSV SCARICATO COME AWSSecretKey
Default region name [None]: REGION (es. us-east-1)
Default output format [None]: json


Terraform troverà automaticamente le credenziali per accedere alle risorse del nostro account AWS


# Utilizzo di terraform 0.12, configurazione finale del cluster e miglioramento configurazione

Entra nella cartella di terraform con:
- cd Terraform

ed eseguire:
- terraform init
- terraform apply

Scrivere "yes" e premere Invio per confermare.
Questo creerà due nuove istanze con le stesse caratteristiche dell'AMI creato in precedenza.
Nella stessa cartella Terraform in cui sono state create può essere eseguito il comando:
- terraform destroy

per distruggere le istanze create con terraform (nessun'altra istanza verrà distrutta).

NOTA: dopo aver effettuato qualche modifica alla configurazione eseguire terraform destroy e riniziare 

Per la parte successiva torniamo nella nostra home con:
- cd ..    (dato che siamo nella cartella Terraform)    oppure   - cd /home/ubuntu

Affinché tutto funzioni sono da modificare 4 file nel master:

File 1. /etc/hosts
A questo file bisogna aggiungere gli indirizzi privati delle istanze create con terraform:
- sudo nano /etc/hosts      (per aprire e modificare il file)

e aggiungere dentro:

PRIVATE_IP datanode*       (* va sostituito con un numero, per esempio datanode2, datanode3 ecc.)

da scrivere per ciascuna istanza creata.

File 2. /home/ubuntu/.ssh/config
File di configurazione di SSH:
- nano /home/ubuntu/.ssh/config      (per aprire e modificare il file)

e aggiungere dentro:

Host datanode*          (* va sostituito con un numero, per esempio datanode2, datanode3 ecc.)
HostName datanode*
User ubuntu
IdentityFile /home/ubuntu/.ssh/my-key.pem

da scrivere per ciascuna istanza creata.

File 3. $HADOOP_CONF_DIF/workers
File di configurazione di hadoop:
- nano $HADOOP_CONF_DIF/workers      (per aprire e modificare il file)

e aggiungere dentro:

datanode*          (* va sostituito con un numero, per esempio datanode2, datanode3 ecc.)

da scrivere per ciascuna istanza creata.

File 4. /home/ubuntu/spark/conf/slaves
File di configurazione di hadoop:
- nano /home/ubuntu/spark/conf/slaves      (per aprire e modificare il file)

e aggiungere dentro:

datanode*          (* va sostituito con un numero, per esempio datanode2, datanode3 ecc.)

da scrivere per ciascuna istanza creata.

Questi file sono stati modificati solo sul master, ma i primi 3 devono essere identici anche in tutte le altre istanze.
La modifica può essere fatta direttamente dal master con alcuni comandi già visti in precedenza:

- cat /etc/hosts | ssh datanode* "sudo sh -c 'cat >/etc/hosts'"
- cat /home/ubuntu/hadoop/etc/hadoop/workers | ssh datanode* "sudo sh -c 'cat >/home/ubuntu/hadoop/etc/hadoop/workers'"
- cat /home/ubuntu/.ssh/config | ssh datanode* "sudo sh -c 'cat >/home/ubuntu/.ssh/config'"

* va sostituito con un numero, per esempio datanode2, datanode3 ecc. e i comandi vanno fatti per ciascun istanza.

Tutta questa procedura può essere lunga e può essere automatizzata grazie a terraform e ad alcuni script.

Modificare il file main.tf:
- nano Terraform/main.tf

e il contenuto del file dovrà essere:


provider "aws" {
  profile = "default"
  region = "REGION"
}

resource "aws_instance" "testInstances" {
   ami = "AMI_ID"
   instance_type = "INSTANCE_TYPE"
   subnet_id = "SUBNET_ID"
   vpc_security_group_ids = [
      "SECURITY_GROUP_ID",
   ]
   count = NUM_INSTANCES
}

resource "null_resource" "testInstances" {
   provisioner "local-exec" {
      command = join("_", aws_instance.testInstances.*.private_ip)
      interpreter = ["bash", "/home/ubuntu/clusterSetup.sh", "MY-KEY", "INDEX_START"]
   }

   provisioner "local-exec" {
      when = destroy
      command = NUM_INSTANCES
      interpreter = ["bash", "/home/ubuntu/clusterClean.sh", "INDEX_START"]
      on_failure = continue
   }
}


Bisogna sostituire MY-KEY col nome della propria chiave privata SSH, NUM_INSTANCES col numero delle istanze,
INDEX_START con l'indice da cui partono i datanodes, ovvero con un valore pari a 7 i nodi si chiameranno "datanode7", "datanode8", "datanode9" e così via
allo stesso modo i valori in maiuscolo sono da sostituire appropriatamente.

%%% L'utilizzo del parametro "interpreter" in questo modo è logicamente sbagliato, ma non funziona in altro modo, %%%
%%% probabilmente a causa di un bug di terraform                                                                  %%%

Questa configurazione fa uso di due file "clusterSetup.sh" e "clusterClean.sh" che non esistono, quindi andiamo a crearli nella nostra home:
- nano clusterSetup.sh

e scriviamo dentro:


#!/bin/bash

cat /etc/hosts > /home/ubuntu/.tmpHosts
cat /home/ubuntu/.ssh/config > /home/ubuntu/.tmpSSHConfig


index=$2
IFS='_' read -ra IPs <<<$3
for i in ${IPs[@]}; do
    awk -v ip="$i" -v idx="$index" '!x{x=sub(/^$/,ip" datanode"idx"\n")}1' /etc/hosts > _tmp && sudo mv _tmp /etc/hosts
    echo -e "Host datanode${index}\nHostName datanode${index}\nUser ubuntu\nIdentityFile /home/ubuntu/.ssh/${1}.pem" >> /home/ubuntu/.ssh/config
    echo "datanode${index}" | sudo tee -a /home/ubuntu/hadoop/etc/hadoop/workers
    echo "datanode${index}" | sudo tee -a /home/ubuntu/spark/conf/slaves
    index=$((index + 1))
done


per il secondo file:
- nano clusterClean.sh

e scriviamo dentro:


#!/bin/bash

n_datanodes=$2
END=$((n_datanodes+2))
for ((i=$1;i<END;i++)); do
     ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "datanode"$i
done

sudo rm -r /home/ubuntu/hadoop/data/namenode
sudo rm -r /home/ubuntu/hadoop/data/datanode
sudo echo "datanode1" > /home/ubuntu/hadoop/etc/hadoop/workers
sudo echo "datanode1" > /home/ubuntu/spark/conf/slaves
sudo mv /home/ubuntu/.tmpHosts /etc/hosts
sudo mv /home/ubuntu/.tmpSSHConfig /home/ubuntu/.ssh/config
sudo rm -r /tmp/*



Salviamo e diamo tutti i permessi ai file con:
- chmod 777 clusterSetup.sh
- chmod 777 clusterClean.sh

A questo punto possiamo avviare terraform come mostrato in precedenza, ma prima bisognerà spostarsi nella cartella:
- cd Terraform
- terraform init
- terraform apply

scrivere yes e premere Invio per confermare.

Per la parte successiva torniamo nella nostra home con:
- cd ..    (dato che siamo nella cartella Terraform)    oppure   - cd /home/ubuntu


Abbiamo aggiornato la configurazione all'interno del master, ma bisogna aggiornare anche i dati dei datanodes.
Per farlo possiamo creare un nuovo script a piacere (ex. updateDatanodes.sh):
- nano updateDatanodes.sh

e scriviamo dentro:


#!/bin/bash

n_datanodes=$2
END=$((n_datanodes+2))
for ((i=$1;i<END;i++)); do
    cat /etc/hosts | ssh -oStrictHostKeyChecking=no datanode$i "sudo sh -c 'cat >/etc/hosts'"
    cat /home/ubuntu/hadoop/etc/hadoop/workers | ssh -oStrictHostKeyChecking=no datanode$i "sudo sh -c 'cat >/home/ubuntu/hadoop/etc/hadoop/workers'"
    cat /home/ubuntu/.ssh/config | ssh -oStrictHostKeyChecking=no datanode$i "sudo sh -c 'cat >/home/ubuntu/.ssh/config'"
done


Salviamo e diamo tutti i permessi al file con:
- chmod 777 updateDatanodes.sh

Per eseguirlo il comando è:
- bash updateDatanodes.sh INDEX_START NUM_INSTANCES

INDEX_START bisogna sostituirlo con l'indice del primo datanode (es. 4 se il primo datanode è "datanode4")
NUM_NODES bisogna sostituirlo col numero di nodi che sono stati creati.


A questo punto possiamo avviare hadoop, yarn e spark come descritto nelle sezioni precedenti.

Quando si distruggeranno le macchine con "terraform destroy" si avvierà lo script "clusterClean.sh"
che pulirà i file di configurazione di hadoop, spark, degli IP e della configurazione SSH permettendoci quindi
di poter rieseguire i comandi "init" e "apply" di terraform senza doverci preoccupare di pulire i file di configurazione.

# Descrizione non raffinata dell'utilizzo di Terraform con istanze di account multipli
Se vuoi usare Terraform come appena descritto, ma creare un cluster con istanze di 2 o più account, sarà necessario creare un "falso master"
negli altri account (viene nominato falso perché "namenode" sarà sempre il master del cluster).

Descriviamo un esempio con 2 soli account.
Per ottenere questo cluster sarà necessario condividere l'AMI con l'altro account e far in modo che l'altro account crei una sola istanza con quell'AMI,
dentro la stessa subnet creata in precedenza, con lo stesso security group e con la stessa key pair (questo si può ottenere leggendo le prime sezione della guida,
ed è semplificato quando gli account fanno parte della stessa organizzazione) e si dia il nome di "datanode17" a quest'istanza. È necessario installare
Terraform nell'istanza "datanode17" e configurato con gli script descritti sopra. Infine chiedi all'altro account l'indirizzo IPv4 di "datanode17".

Adesso è necessario modificare i file di configurazione solo di "datanode17".
Bisogna inserire l'indirizzo IPv4 nel file /etc/hosts e settare "datanode17" come hostname, bisogna modificare il file config di SSH con questo nuovo hostname
"datanode17", aggiungere "datanode17" al file workers di Hadoop e aggiungere "datanode17" al file slaves di Spark.

Adesso bisogna eseguire "terraform init" e "terraform apply" solo in "datanode17", ma bisogna stare attenti con INDEX_START e NUM_INSTANCES perché non bisogna
creare doppioni, tutti i datanodes devono avere un nome diverso, quindi un diverso indice.

Il prossimo passo è copiare i file di configurazione di "datanode17" in "namenode" con i seguenti comandi:
- cat /etc/hosts | ssh namenode "sudo sh -c ’cat >/etc/hosts’"       ( per aggiornare hostnames )
- cat /home/ubuntu/.ssh/config | ssh namenode "sudo sh -c ’cat >/home/ubuntu/.ssh/config’"        ( per aggiornare SSH config )
- cat /home/ubuntu/hadoop/etc/hadoop/workers | ssh namenode "sudo sh -c ’cat >/home/ubuntu/hadoop/etc/hadoop/workers’"  ( per aggiornare workers )
- cat /home/ubuntu/spark/conf/slaves | ssh namenode "sudo sh -c ’cat >/home/ubuntu/spark/conf/slaves’"  ( per aggiornare slaves )
Dopo questo passaggio bisogna tornare alla shell del master (namenode). Qui dobbiamo eseguire "terraform init" e "terraform apply".

L'ultimo passo è eseguire lo script updateDatanode.sh, ma bisogna usare l'INDEX_START minore tra i due, tra quello di "namenode" e quello di "datanode17"
e la somma dei NUM_INSTANCES di "namenode" e "datanode17" più 1, perché bisogna contare anche "datanode17".
È necessario che i nomi dei datanodes siano contigui affinché lo script funzioni, per esempio l'ultimo datanode creato da "namenode" dev'essere "datanode16"
e i datanodes creati da "datanode17" devono iniziare da "datanode18".

Quando si esegue "terraform destroy" in entrambe le istanze, alcuni file di configurazione di "namenode" devono essere puliti:
/etc/hosts e /home/ubuntu/.ssh/config perché lo script clusterClean.sh porterà questi file alla versione originale, ma la loro versione originale era stata modificata
con i valori copiati da "datanode17". I file workers e slaves conterranno solo il valore "datanode1" come all'inizio.

---------------------------------------------------------------------------------------------------------------------------------------------------------------

# Inizializzare e avviare HDFS
- hdfs namenode -format
- start-dfs.sh

@ Test: fai una directory e controlla se sia stata fatta
- hadoop fs -mkdir /test
- hadoop fs -ls / (dovrebbe comparire '/test' nell'output)

@ Test: controlla i datanodes attivi (live) DEVONO ESSERE TANTI QUANTO I NODI NEL CLUSTER
- hdfs dfsadmin -report

IMPORTANTE: nel caso in cui il comando " hdfs dfsadmin -report " restituisse 0 o meno nodi di quanto attesi bisogna eseguire le seguenti procedure:

1. Cancellare la cartella "datanode" per tutti i nodi e per il master ANCHE la cartella "namenode" che si trovanno al path "hadoop/data/". Il comando è:

- rm -r $HADOOP_HOME/data/datanode      (per tutti i nodi, anche per il master dato che viene usato anche come worker)
- rm -r $HADOOP_HOME/data/namenode      (solo per il master)

Per velocizzare il lavoro, se SSH è configurato correttamente potremo eseguire il comando direttamente dal master.
Per esempio se si vuole cancellare la cartella "datanode" da una certa macchina datanode2 si può eseguire dalla shell del master il comando:

- ssh datanode2 "sudo sh -c 'rm -r /home/ubuntu/hadoop/data/datanode'"

2. Cancellare i file all'interno della cartella "tmp" in ogni nodo col comando:

- sudo rm -r /tmp/*

Allo stesso modo si può eseguire da remoto con (nell'esempio si usa datanode2):

- ssh datanode2 "sudo sh -c 'sudo rm -r /tmp/*'"

Non appena fatte queste procedure bisogna riformattare hdfs, avviarlo e testare di nuovo il numero di nodi, ovvero i comandi nella sezione # Inizializzare HDFS


# Avviare YARN
-------------
- start-yarn.sh

@ Test: devono uscire tanti nodi quanti datanodes
- yarn node -list

HINT: usare il comando rapido 'jps' che mostra i processi della JVM (quindi Hadoop) in running

Esiste anche il comando:
- start-all.sh
ma Hadoop consiglia di utilizzare i due comandi sopra citati per avviare hdfs e yarn

Gli stessi possono essere stoppati con i comandi:
- stop-dfs.sh
- stop-yarn.sh

oppure col comando:
- stop-all.sh


# Avviare Spark
- ./spark/sbin/start-master.sh
- ./spark/sbin/start-slaves.sh

Per fare il submit di un file python col cluster il comando è
- ./spark/bin/spark-submit --master yarn --deploy-mode client PATH_FILE_PYTHON

Per specificare il numero di nodi (executors) aggiungere il parametro "--num-executors X" con X = numero di esecutori. Un esempio sarebbe:
- ./spark/bin/spark-submit --master yarn --deploy-mode client --num-executors 8 testSample.py

In caso di errore (pyspark module not found) sull'oggetto restituito da SparkConf() aggiungere:

- .set('spark.yarn.dist.files','/home/ubuntu/spark/python/lib/pyspark.zip,/home/ubuntu/spark/python/lib/py4j-0.10.7-src.zip').setExecutorEnv('PYTHONPATH','pyspark.zip:py4j-0.10.7-src.zip')

ESEMPIO: SparkConf().set('spark.yarn.dist.......ECC

Si può vedere un report delle macchine avviate per spark e visualizzare lo stato delle applicazioni avviate, gli errori e i tempi di esecuzione.
Prima di tutto bisogna tornare su AWS e modificare i security group, aggiungere una regola:
 All traffic - My IP

Poi entrare sul sito web:
- http://PUBLIC_DNS_ADDRESS:PORT

Dalla porta 8080 si potranno visualizzare le macchine avviate per spark e altre informazioni.
Dalla porta 8088 potremmo analizzare pienamente lo stato delle applicazioni avviate con spark, e quindi è l'interfaccia migliore da utilizzare
per vedere errori incontrati durante l'esecuzione, se l'applicazione è andata a buon fine, tempi di esecuzione ecc.
