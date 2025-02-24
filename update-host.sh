#!/bin/bash

DB_USER="marzban"
DB_NAME="marzban"

echo -n "Enter host ID (e.g., '10'): "
read HOST_ID

echo -n "Marzban DB password: "
read DB_PASSWORD

echo "Select inbound type:"
echo "1. VLESS Reality Steal Oneself"
echo "2. VLESS WS Tls"
echo "3. VLESS HTTPUpgrade TLS"
echo -n "Enter your choice (1, 2, or 3): "
read CHOICE

case "$CHOICE" in
    1)
        INBOUND_TAG="VLESS Reality Steal Oneself"
        echo -n "Enter value for remark (e.g., '🇩🇪 Быстрый 🚀', '🇩🇪 Устойчивый 🛡️'): "
        read REMARK
        echo -n "Enter value for address (e.g., 'example.com'): "
        read ADDRESS
        SNI="$ADDRESS"
        SQL_QUERY="
        SET NAMES utf8mb4;
        UPDATE hosts 
        SET 
            remark = '$REMARK', 
            address = '$ADDRESS', 
            inbound_tag = '$INBOUND_TAG', 
            sni = '$SNI' 
        WHERE id = $HOST_ID;
        "
        ;;
    2)
        INBOUND_TAG="VLESS WS Tls"
        echo -n "Enter value for remark (e.g., '🇩🇪 Быстрый 🚀', '🇩🇪 Устойчивый 🛡️'): "
        read REMARK
        echo -n "Enter value for address (e.g., 'example.com'): "
        read ADDRESS
        echo -n "Enter value for path (e.g., '/path + ?ed=2560'): "
        read PATH
        SNI="$ADDRESS"
        HOST="$ADDRESS"
        SQL_QUERY="
        SET NAMES utf8mb4;
        UPDATE hosts 
        SET 
            remark = '$REMARK', 
            address = '$ADDRESS', 
            inbound_tag = '$INBOUND_TAG', 
            sni = '$SNI', 
            host = '$HOST', 
            path = '$PATH', 
            security = 'tls' 
        WHERE id = $HOST_ID;
        "
        ;;
    3)
        INBOUND_TAG="VLESS HTTPUpgrade TLS"
        echo -n "Enter value for remark (e.g., '🇩🇪 Быстрый 🚀', '🇩🇪 Устойчивый 🛡️'): "
        read REMARK
        echo -n "Enter value for address (e.g., 'example.com'): "
        read ADDRESS
        echo -n "Enter value for path (e.g., '/path + ?ed=2560'): "
        read PATH
        SNI="$ADDRESS"
        HOST="$ADDRESS"
        SQL_QUERY="
        SET NAMES utf8mb4;
        UPDATE hosts 
        SET 
            remark = '$REMARK', 
            address = '$ADDRESS', 
            inbound_tag = '$INBOUND_TAG', 
            sni = '$SNI', 
            host = '$HOST', 
            path = '$PATH', 
            security = 'tls' 
        WHERE id = $HOST_ID;
        "
        ;;
    *)
        echo "Invalid choice. Please enter 1, 2, or 3."
        exit 1
        ;;
esac

CONTAINER_ID=$(docker ps -q -f "name=mariadb")

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No running container found with name 'mariadb'. Trying to find by image 'mariadb:lts'..."
    CONTAINER_ID=$(docker ps -q -f "ancestor=mariadb:lts")
    if [ -z "$CONTAINER_ID" ]; then
        echo "Error: No running container found with image 'mariadb:lts' either. Please check your Docker setup."
        exit 1
    fi
fi

echo "Found container ID: $CONTAINER_ID"

echo "Connecting to MariaDB container $CONTAINER_ID and updating hosts table..."
docker exec -i "$CONTAINER_ID" mariadb -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<EOF
$SQL_QUERY
EOF

if [ $? -eq 0 ]; then
    echo "Record with id = $HOST_ID updated successfully."
else
    echo "Error occurred while updating the record."
    exit 1
fi

echo "Restarting Marzban..."
marzban restart
