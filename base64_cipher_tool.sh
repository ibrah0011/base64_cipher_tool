#!/bin/bash

# Function to encode a string in Base64
encode_base64() {
    echo -n "$1" | base64
}

# Function to decode a Base64 encoded string
decode_base64() {
    echo -n "$1" | base64 --decode
}

# Function to apply Caesar Cipher (encryption and decryption)
caesar_cipher() {
    local shift=$1
    local text=$2
    echo "$text" | tr 'A-Za-z' "$(echo {A..Z}{A..Z} | cut -c$((shift+1))-$((shift+26)))$(echo {a..z}{a..z} | cut -c$((shift+1))-$((shift+26)))"
}

# Function to apply Vigenère Cipher (placeholder, needs implementation)
vigenere_cipher() {
    echo "Vigenère Cipher is not yet implemented."
}

# Function to apply Atbash Cipher
atbash_cipher() {
    echo "$1" | tr 'A-Za-z' 'Z-Az-a'
}

# Function to apply Rot13 Cipher
rot13_cipher() {
    echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

# Function to apply Custom Cipher (placeholder, needs implementation)
custom_cipher() {
    echo "Custom Cipher is not yet implemented."
}

# Function to apply cipher before encoding
apply_cipher() {
    local text=$1
    local cipher_type=$2
    local shift=3

    case $cipher_type in
        "Caesar Cipher")
            text=$(caesar_cipher $shift "$text")
            ;;
        "Vigenère Cipher")
            text=$(vigenere_cipher "$text")
            ;;
        "Atbash Cipher")
            text=$(atbash_cipher "$text")
            ;;
        "Rot13 Cipher")
            text=$(rot13_cipher "$text")
            ;;
        "Custom Cipher")
            text=$(custom_cipher "$text")
            ;;
        *)
            echo "Invalid cipher type"
            return
            ;;
    esac
    echo "$text"
}

# Function to reverse cipher after decoding
reverse_cipher() {
    local text=$1
    local cipher_type=$2
    local shift=3

    case $cipher_type in
        "Caesar Cipher")
            text=$(caesar_cipher $((26 - shift)) "$text")
            ;;
        "Vigenère Cipher")
            text=$(vigenere_cipher "$text")
            ;;
        "Atbash Cipher")
            text=$(atbash_cipher "$text")
            ;;
        "Rot13 Cipher")
            text=$(rot13_cipher "$text")
            ;;
        "Custom Cipher")
            text=$(custom_cipher "$text")
            ;;
        *)
            echo "Invalid cipher type"
            return
            ;;
    esac
    echo "$text"
}

# Function to handle the encryption process
encrypt() {
    CIPHER_SELECTED="None"
    case $1 in
        1)
            read -p "Enter the URL: " INPUT
            ;;
        2)
            read -p "Enter the text: " INPUT
            ;;
        3)
            read -p "Enter the file path: " FILE_PATH
            if [ -f "$FILE_PATH" ]; then
                INPUT=$(cat "$FILE_PATH")
            else
                echo "File not found!"
                return
            fi
            ;;
        4)
            read -p "Enter the hexadecimal string: " HEX_INPUT
            INPUT=$(echo "$HEX_INPUT" | xxd -r -p)
            ;;
        5)
            read -p "Enter the JSON string: " INPUT
            ;;
        6)
            read -p "Enter the URL for Base64 URL encoding: " INPUT
            INPUT=$(echo -n "$INPUT" | base64 | tr '+/' '-_' | tr -d '=')
            ;;
        7)
            read -p "Enter the binary file path: " FILE_PATH
            if [ -f "$FILE_PATH" ]; then
                INPUT=$(base64 "$FILE_PATH")
                echo "Encoded binary content: $INPUT"
                return
            else
                echo "File not found!"
                return
            fi
            ;;
        8)
            read -p "Enter the text for custom encoding: " INPUT
            # Apply custom encoding transformation here (e.g., character transformation)
            INPUT=$(echo "$INPUT" | tr 'a-z' 'A-Z')
            ;;
        9)
            read -p "Enter the text to cipher: " INPUT
            echo "Select the cipher type:"
            select CIPHER in "Caesar Cipher" "Vigenère Cipher" "Atbash Cipher" "Rot13 Cipher" "Custom Cipher"; do
                case $REPLY in
                    1|2|3|4|5 ) 
                        INPUT=$(apply_cipher "$INPUT" "$CIPHER")
                        CIPHER_SELECTED="$CIPHER"
                        break
                        ;;
                    * ) echo "Invalid selection";;
                esac
            done
            ;;
        *)
            echo "Invalid input type!"
            return
            ;;
    esac
    ENCODED_INPUT=$(encode_base64 "$INPUT")
    echo "Encoded content: $ENCODED_INPUT"
    echo "$ENCODED_INPUT" > encoded_output.txt
    echo "$CIPHER_SELECTED" > cipher_type.txt
}

# Function to handle the decryption process
decrypt() {
    read -p "Enter the Base64 encoded string or file path: " ENCODED_INPUT
    if [ -f "$ENCODED_INPUT" ]; then
        ENCODED_INPUT=$(cat "$ENCODED_INPUT")
    fi
    DECODED_INPUT=$(decode_base64 "$ENCODED_INPUT")
    echo "Decoded content: $DECODED_INPUT"

    if [ -f "cipher_type.txt" ]; then
        CIPHER_SELECTED=$(cat "cipher_type.txt")
    else
        CIPHER_SELECTED="None"
    fi

    if [ "$CIPHER_SELECTED" != "None" ]; then
        DECRYPTED_TEXT=$(reverse_cipher "$DECODED_INPUT" "$CIPHER_SELECTED")
    else
        DECRYPTED_TEXT="$DECODED_INPUT"
    fi

    echo "Decrypted content: $DECRYPTED_TEXT"
}

# Main script starts here
echo "Do you want to encrypt or decrypt?"
select ACTION in "Encrypt" "Decrypt"; do
    case $ACTION in
        Encrypt ) MODE="encrypt"; break;;
        Decrypt ) MODE="decrypt"; break;;
    esac
done

if [ "$MODE" == "encrypt" ]; then
    echo "Select the input type:"
    select TYPE in "URL" "Text" "File" "Hexadecimal" "JSON" "Base64 URL" "Binary" "Custom Encoding" "Cipher"; do
        case $REPLY in
            1|2|3|4|5|6|7|8|9 ) encrypt "$REPLY"; break;;
            * ) echo "Invalid selection";;
        esac
    done
elif [ "$MODE" == "decrypt" ]; then
    decrypt
fi
