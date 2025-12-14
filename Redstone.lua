-- 1. Carica le API necessarie
local component = require("component")
local sides = require("sides")
local term = require("term")
local colors = require("colors")

-- 2. Tenta di ottenere un proxy per la scheda/blocco Redstone
-- OpenComputers gestisce la Redstone tramite un componente specifico,
-- che può essere una Redstone Card in uno slot o un Redstone I/O Block adiacente.
local rs = component.get("redstone")

-- 3. Definisci le costanti e lo stato
local OUTPUT_SIDE = sides.top  -- Sostituisci con il lato dove vuoi che esca il segnale (es. sides.bottom, sides.front, ecc.)
local LIGHTS_ON = 15           -- Livello massimo di segnale Redstone (acceso)
local LIGHTS_OFF = 0           -- Livello minimo di segnale Redstone (spento)
local is_on = false            -- Variabile per tracciare lo stato attuale (spento di default)

-- 4. Funzione per disegnare lo stato sullo schermo (opzionale ma utile)
local function update_display(message)
    -- Seleziona lo schermo (se collegato)
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
        
        -- Sblocca il terminale dalla schermata grafica per poter usare il comando read()
        term.unbind()
    else
        -- Se non c'è schermo, stampa solo sulla console
        print("Stato: " .. (is_on and "ACCESO" or "SPENTO"))
        print(message)
    end
end

-- 5. Ciclo principale del programma
if not rs then
    print("Errore: Componente Redstone non trovato. Inserisci una Redstone Card o un Redstone I/O Block.")
    return -- Ferma lo script
end

update_display("Inizializzazione...")

-- Ciclo infinito per attendere i comandi
while true do
    -- Ottiene l'input dall'utente
    update_display("Inserisci un comando:")
    -- La funzione read() attende un input sulla console
    local command = io.read() 
    
    -- Normalizza il comando (rende minuscolo e rimuove spazi)
    command = string.lower(string.gsub(command, "^%s*(.-)%s*$", "%1"))
    
    if command == "esci" or command == "quit" then
        update_display("Spegnimento dello script. Arrivederci.")
        break -- Esce dal ciclo while
        
    elseif command == "on" or command == "1" then
        if not is_on then
            -- Imposta il segnale Redstone sul lato definito
            rs.setOutput(OUTPUT_SIDE, LIGHTS_ON)
            is_on = true
            update_display("Luci ACCESE.")
        else
            update_display("Le luci sono già accese.")
        end
        
    elseif command == "off" or command == "0" then
        if is_on then
            -- Spegne il segnale Redstone
            rs.setOutput(OUTPUT_SIDE, LIGHTS_OFF)
            is_on = false
            update_display("Luci SPENTE.")
        else
            update_display("Le luci sono già spente.")
        end
        
    elseif command == "toggle" then
        -- Inverte lo stato
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

-- Assicurati di spegnere il segnale Redstone quando il programma termina
rs.setOutput(OUTPUT_SIDE, LIGHTS_OFF)