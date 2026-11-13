#!/bin/bash

RED='\033[0;31m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${PURPLE}"
    echo "   ███████╗██████╗  ██╗███╗   ██╗ ██████╗ "
    echo "   ██╔════╝██╔══██╗███║████╗  ██║██╔════╝ "
    echo "   ███████╗██████╔╝╚██║██╔██╗ ██║██║  ███╗"
    echo "   ╚════██║██╔═══╝  ██║██║╚██╗██║██║   ██║"
    echo "   ███████║██║      ██║██║ ╚████║╚██████╔╝"
    echo "   ╚══════╝╚═╝      ╚═╝╚═╝  ╚═══╝ ╚═════╝ "
    echo -e "${NC}"
    echo -e "${CYAN}=== SP1NG Roblox & Network Toolkit ===${NC}\n"

    echo -e "${YELLOW}1.${NC} HTTP Request Spammer\n"
    echo -e "${YELLOW}2.${NC} Display Local & Public IP\n"
    echo -e "${YELLOW}3.${NC} Roblox Username Availability Checker\n"
    echo -e "${YELLOW}4.${NC} Roblox Game Stats Viewer (Place ID)\n"
    echo -e "${YELLOW}5.${NC} Exit\n"
    echo -n "Choose an option: "
}

http_spammer() {
    echo -e "\n${CYAN}--- HTTP Request Spammer ---${NC}"
    read -p "Target URL (e.g., https://example.com): " target_url
    read -p "Method (GET / POST): " method
    method=$(echo "$method" | tr '[:lower:]' '[:upper:]')
    
    read -p "Number of requests: " count
    
    read -p "Header Key [Leave empty if none]: " header_key
    custom_headers=""
    if [ -n "$header_key" ]; then
        read -p "Header Content: " header_content
        custom_headers="$header_key: $header_content"
    fi
    
    body=""
    if [ "$method" == "POST" ]; then
        read -p "Body Key [Leave empty if none]: " body_key
        if [ -n "$body_key" ]; then
            read -p "Body Content: " body_content
            body="$body_key=$body_content"
        else
            read -p "Full Request Body (or leave empty): " body
        fi
    fi

    echo -e "\n${GREEN}Launching $count requests...${NC}\n"

    for ((i=1; i<=count; i++)); do
        if [ "$method" == "POST" ]; then
            if [ -z "$custom_headers" ]; then
                response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -d "$body" "$target_url")
            else
                response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "$custom_headers" -d "$body" "$target_url")
            fi
        else
            if [ -z "$custom_headers" ]; then
                response=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$target_url")
            else
                response=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H "$custom_headers" "$target_url")
            fi
        fi
        echo -e "Request $i/$count — HTTP Status: $response"
    done
}

ip_info() {
    echo -e "\n${CYAN}--- Local & Public IP Info ---${NC}"
    local_ip=$(hostname -I 2>/dev/null || ip route get 1 2>/dev/null | awk '{print $7; exit}')
    if [ -z "$local_ip" ]; then
        local_ip=$(ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
    fi
    echo -e "Local Network IP : ${GREEN}${local_ip:-Not found}${NC}"
    
    public_ip=$(curl -s https://api.ipify.org)
    echo -e "Public IP        : ${GREEN}${public_ip:-Unavailable}${NC}"
}

roblox_username_checker() {
    echo -e "\n${CYAN}--- Roblox Username Availability Checker ---${NC}"
    read -p "Enter username to check: " username
    
    response=$(curl -s -X POST "https://users.roblox.com/v1/usernames/users" \
        -H "Content-Type: application/json" \
        -d "{\"usernames\": [\"$username\"], \"excludeBannedUsers\": false}")
    
    if echo "$response" | grep -q "\"name\":\"$username\""; then
        echo -e "Username ${RED}$username${NC} is TAKEN."
    else
        echo -e "Username ${GREEN}$username${NC} is AVAILABLE."
    fi
}

roblox_game_stats() {
    echo -e "\n${CYAN}--- Roblox Game Stats Viewer (Place ID) ---${NC}"
    read -p "Enter Roblox Place ID: " place_id
    
    echo -e "\n${GREEN}Fetching game statistics...${NC}"
    response=$(curl -s "https://games.roblox.com/v1/games/multiget-place-details?placeIds=$place_id")
    
    name=$(echo "$response" | grep -o '"name":"[^"]*"' | head -n 1 | cut -d'"' -f4)
    playing=$(echo "$response" | grep -o '"playing":[0-9]*' | head -n 1 | cut -d':' -f2)
    visits=$(echo "$response" | grep -o '"visits":[0-9]*' | head -n 1 | cut -d':' -f2)
    
    if [ -n "$name" ]; then
        echo -e "Game Name : ${GREEN}${name:-N/A}${NC}"
        echo -e "Playing   : ${GREEN}${playing:-0}${NC}"
        echo -e "Visits    : ${GREEN}${visits:-0}${NC}"
    else
        echo -e "${RED}Invalid Place ID or game not found.${NC}"
    fi
}

if [ $# -gt 0 ]; then
    "$@"
    exit 0
fi

while true; do
    show_menu
    read choice
    case "$choice" in
        1) http_spammer ;;
        2) ip_info ;;
        3) roblox_username_checker ;;
        4) roblox_game_stats ;;
        5) echo "Exiting."; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
