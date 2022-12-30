# set to true while testing to bypass letsencrypt limits
staging=false
# RSA Size
rsa_key_size=4096
# authority for the certs
email="fokko.vos.ipso@gmail.com"
# get current time (start of script) for backups & processing marks
current_time=$(date '+%Y-%m-%d')

# confirm key
confirm="y"


config_base_dir="webctl/configs"
wordpress_base_dir="wordpress"

# wir wollen die http versionen auf den lokalen port binden damit diese nur ueber die Proxy erreichbar sind
ip="127.0.0.1"