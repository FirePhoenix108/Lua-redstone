-- 1. Carica le API necessarie
local component = require("component")
local sides = require("sides")
local term = require("term")
local colors = require("colors")

-- 2. Tenta di ottenere un proxy per la scheda Redstone
local rs = component.get("redstone")

-- 3. Definisci le costanti e lo stato
local OUTPUT_SIDE = sides.right -- Modificato per il blocco I/O sulla destra
local LIGHTS_ON = 15           
local LIGHTS_OFF = 0           
local is_on = false            

-- 4. Funzione per disegnare lo stato sullo schermo
local function update_display(message)
    local screen_proxy = component.get("screen")
    if screen_proxy then
        term.bind(screen_proxy.address)
        term.clear()
        term.setCursor(1, 1)
        term.setForeground(colors.yellow)
        term.write("--- Pannello di Controllo Luce ---")
        
        term.setCursor(1, 3)
        if is_on then
            term.setForeground(colors.lime)
            term.write("STATO ATTUALE: LUCI ACCESE (ON)")
        else
            term.setForeground(colors.red)
            term.write("STATO ATTUALE: LUCI SPENTE (OFF)")
        end
        
        term.setCursor(1, 5)
        term.setForeground(colors.white)
        term.write(message)
        
        term.setCursor(1, 7)
        term.write("Comandi: 'on', 'off', 'toggle', 'esci'")
        
        term.unbind() -- Importante per permettere l'input da read()
    else
        print("Stato: " .. (is_on and "ACCESO" or "SPENTO"))
        print(message)
    end
end

-- 5. Ciclo principale del programma
if not rs then
    print("Errore CRITICO: Componente Redstone non trovato. Riavviare il PC o reinstallare la scheda.")
    return -- Ferma lo script
end

update_display("Sistema Redstone ONLINE. Inserisci un comando:")

while true do
    local command = io.read() 
    command = string.lower(string.gsub(command, "^%s*(.-)%s*$", "%1"))
    
    if command == "esci" or command == "quit" then
        update_display("Spegnimento dello script.")
        break
        
    elseif command == "on" or command == "1" then
        if not is_on then
            rs.setOutput(OUTPUT_SIDE, LIGHTS_ON)
            is_on = true
            update_display("Luci ACCESE.")
        else
            update_display("Le luci sono già accese.")
        end
        
    elseif command == "off" or command == "0" then
        if is_on then
            rs.setOutput(OUTPUT_SIDE, LIGHTS_OFF)
            is_on = false
            update_display("Luci SPENTE.")
        else
            update_display("Le luci sono già spente.")
        end
        
    elseif command == "toggle" then
        if is_on then
            rs.setOutput(OUTPUT_SIDE, LIGHTS_OFF)
            is_on = false
            update_display("Stato invertito: SPENTO.")
        else
            rs.setOutput(OUTPUT_SIDE, LIGHTS_ON)
            is_on = true
            update_display("Stato invertito: ACCESO.")
        end
        
    else
        update_display("Comando non riconosciuto. Usa 'on', 'off', 'toggle' o 'esci'.")
    end
end

-- Cleanup finale
rs.setOutput(OUTPUT_SIDE, LIGHTS_OFF)
