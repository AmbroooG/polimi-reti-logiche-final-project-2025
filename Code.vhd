library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;     
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        o_done  : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0); 
        i_mem_data : in std_logic_vector(7 downto 0); 
        o_mem_data : out std_logic_vector(7 downto 0); 
        o_mem_we : out std_logic;
        o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (S0, S1, S2, S3, S4, S5, S6);
    signal curr_state , next_state : state_type;
    signal K : std_logic_vector(15 downto 0);
    signal S : std_logic;
    signal mod3 : std_logic_vector(39 downto 0);
    signal mod5 : std_logic_vector(55 downto 0);
    signal sequenceNumb_mod3 : std_logic_vector(39 downto 0);
    signal sequenceNumb_mod5 : std_logic_vector(55 downto 0);
    signal counter : unsigned(15 downto 0);
    signal reg_load : std_logic;
    
begin
    --------------------------------------------------
    -- Process sincronizzati per cambiamento di stati
    --------------------------------------------------
    process(i_clk , i_rst)
    begin
        if(i_rst = '1') then
            curr_state <= S0;
        elsif(rising_edge(i_clk)) then
            curr_state <= next_state;
        end if;
    end process;

    ---------------------------------------------------
    -- Process che gestisce le transizioni dei stati
    ---------------------------------------------------
    process(curr_state, i_start, counter, S)
    begin
        next_state <= curr_state;
        case curr_state is
        
            -- inizia nuovo input
            when S0 => 
                if (i_start = '1') then
                    next_state <= S1;
                end if;
                
            -- per salvare i primi numeri da calcolare 
            when S1 =>
                -- (caso mod3) S1 rimane quando ha finito di salvare i primi 3 numeri di sequenza K
                if (to_integer(counter) = 20 and S = '0') then 
                    next_state <= S2;
                -- (caso mod5) S1 rimane quando ha finito di salvare i primi 4 numeri di sequenza K
                elsif (to_integer(counter) = 21 and S = '1') then 
                    next_state <= S2;
                else
                    next_state <= S1;
                end if;
                
            -- serve per rendere il calcolo stabile 
            when S2 =>            
                    next_state <= S3;  
                        
            when S3 =>
                -- se sono sequenza di K e-simo allora vado S4 altrimenti vado S2, nel caso se abbiamo finito tutto va S6
                if((to_integer(counter)= to_integer(unsigned(K)) + 20 and S = '0') or (to_integer(counter) = to_integer(unsigned(K)) + 21 and S = '1')) then
                    next_state <= S6;
                elsif (to_integer(counter) >= to_integer(unsigned(K)) + 18) then
                    next_state <= S5;
                else
                    next_state <= S4;
                end if;
               
            when S4 => 
                next_state <= S5;
 
            when S5 =>
                next_state <= S2;
            
            -- Stato finale
            when S6 => 
                if i_start = '0' then
                    next_state <= S0;
                end if;
                
            when others =>
                next_state <= S0;
        end case;
    end process;

    ---------------------
    -- Segnali di stati 
    ---------------------
    process(curr_state)
    begin
        -- default
        o_done <= '0';
        o_mem_en   <= '0';
        o_mem_we   <= '0';
        reg_load   <= '0';
        
        case curr_state is
            when S0 =>
                null;
                
            -- legge e salva parametro K, S, coefficiente di mod3/mod5 e primi numeri da calcolare
            when S1 =>              
                o_mem_en <= '1';
                reg_load <= '1';
            
            -- un clock di attesa per aspettare il calcolo diventa stabile 
            when S2 =>
            
            -- scrive nel RAM
            when S3 =>              
                o_mem_en   <= '1';
                o_mem_we   <= '1';
           
            -- passa l'indirizzo di next numero  
            when S4 =>              
                o_mem_en   <= '1';
            
            -- memorizzo il next numero da i_mem_data
            when S5 =>
                reg_load <= '1';
            
            -- fine done = 1
            when S6 =>              
                o_done <= '1';
           
            when others =>
                null;
        end case;
    end process;

    ----------------------------------------------------------------
    -- Processi per calcolare l'indirizzo di lettura e scrittura
    ----------------------------------------------------------------
    process(counter, K, curr_state, i_start, i_add, S)
        variable base_u : unsigned(15 downto 0);
    begin
        base_u := unsigned(i_add);
        if (i_start = '0') then
            o_mem_addr <= (others => '0');
        -- indirizzo di scrittura 
        elsif (curr_state = S3) then
            -- indirizzo di scrittura: (i_add + counter + K) - 3
            if(S = '0') then
                o_mem_addr <= std_logic_vector( (base_u + counter + unsigned(K)) - to_unsigned(3,base_u'length) );
            -- indirizzo di scrittura: (i_add + counter + K) - 4
            else
                o_mem_addr <= std_logic_vector( (base_u + counter + unsigned(K)) - to_unsigned(4,base_u'length) );
            end if;
        -- indirizzo di lettura
        else
            o_mem_addr <= std_logic_vector( base_u + counter );
        end if;
    end process;

    -----------------------------------------------------------------------------------------------
    -- Process per registrare i parametri: K, S, coefficiente di mod3/mod5 e i numeri da calcolare
    -----------------------------------------------------------------------------------------------
    process(i_clk, i_rst)
    begin
        if(i_rst = '1' or i_start = '0') then
            K <= (others => '0');
            S <= '0';
            mod3 <= (others => '0');
            mod5 <= (others => '0');
            sequenceNumb_mod3 <= (others => '0');
            sequenceNumb_mod5 <= (others => '0');
            counter <= (others => '0');
            
        elsif(rising_edge(i_clk)) then
            if(reg_load = '1') then
                -- salva i primi due elementi nel registro
                if(to_integer(counter) = 1 or to_integer(counter) = 2) then
                    K <= K(7 downto 0) & i_mem_data;

                -- salva ultimo bit di input nel registro S
                elsif(to_integer(counter) = 3) then
                    S <= i_mem_data(0);
                -- salvare le coefficiente di mod3 
                elsif(to_integer(counter) > 4 and to_integer(counter) < 10) then
                    mod3 <= mod3(31 downto 0) & i_mem_data;

                -- salvare le coefficiente di mod5
                elsif(to_integer(counter) > 10 and to_integer(counter) < 18) then
                    mod5 <= mod5(47 downto 0) & i_mem_data;

                -- comincia la sequenza di K
                elsif( (to_integer(counter) > 17) and (to_integer(counter) < 17 + to_integer(unsigned(K))) ) then
                    if(S = '0') then
                        sequenceNumb_mod3 <= sequenceNumb_mod3(31 downto 0) & i_mem_data;
                    else
                        sequenceNumb_mod5 <= sequenceNumb_mod5(47 downto 0) & i_mem_data;
                    end if;

                -- quando finito la sequenza di K
                else
                    if(S = '0') then
                        sequenceNumb_mod3 <= sequenceNumb_mod3(31 downto 0) & "00000000";
                    else
                        sequenceNumb_mod5 <= sequenceNumb_mod5(47 downto 0) & "00000000";
                    end if;
                end if;
                
                 -- per saltare la lettura di coefficiente di mod3 che non sono necessario
                if (counter = 4 and S = '1') then
                    counter <= to_unsigned(10, counter'length);
                -- salta le coefficiente di mod5 che non sono necessari
                elsif(counter = 9 and S = '0') then 
                    counter <= to_unsigned(17, counter'length);
                -- per non saltare il numero nel passaggio di S1 -> S2
                elsif not( (S='0' and to_integer(counter)=20 and curr_state = S1) or (S='1' and to_integer(counter)=21 and curr_state = S1) ) then
                    counter <= counter + 1;
                end if;
                
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Calcolo combinatorio per calcolare il risultato
    ----------------------------------------------------------------
    process(S, sequenceNumb_mod3, sequenceNumb_mod5, mod3, mod5)
        variable sum : signed(17 downto 0) := (others => '0');
        variable o_data_sum : signed(17 downto 0) := (others => '0');
    begin
        -- result    <= (others => '0');
        sum       := (others => '0');
        o_data_sum:= (others => '0');

        if (S = '0') then
            -- somma dei prodotti
            sum := (others => '0');
            sum := sum
                + resize(signed(sequenceNumb_mod3( 7 downto  0)) * signed(mod3( 7 downto  0)), sum'length)
                + resize(signed(sequenceNumb_mod3(15 downto  8)) * signed(mod3(15 downto  8)), sum'length)
                + resize(signed(sequenceNumb_mod3(23 downto 16)) * signed(mod3(23 downto 16)), sum'length)
                + resize(signed(sequenceNumb_mod3(31 downto 24)) * signed(mod3(31 downto 24)), sum'length)
                + resize(signed(sequenceNumb_mod3(39 downto 32)) * signed(mod3(39 downto 32)), sum'length);

            -- la divisione relativo a 1/16, 1/64, 1/256 e 1/1024
            o_data_sum := shift_right(sum,4);
            o_data_sum := o_data_sum + shift_right(sum,6);
            o_data_sum := o_data_sum + shift_right(sum,8);
            o_data_sum := o_data_sum + shift_right(sum,10);
                
            -- nel caso se sum è negativo allora per ogni shift abbiamo bisogno di +1 -> in totale +4
            if(to_integer(sum) < 0) then
                o_data_sum := o_data_sum + to_signed(4, o_data_sum'length);
            end if;
        else
            -- somma dei prodotti 
            sum := (others => '0');
            sum := sum
                + resize(signed(sequenceNumb_mod5( 7 downto  0)) * signed(mod5( 7 downto  0)), sum'length)
                + resize(signed(sequenceNumb_mod5(15 downto  8)) * signed(mod5(15 downto  8)), sum'length)
                + resize(signed(sequenceNumb_mod5(23 downto 16)) * signed(mod5(23 downto 16)), sum'length)
                + resize(signed(sequenceNumb_mod5(31 downto 24)) * signed(mod5(31 downto 24)), sum'length)
                + resize(signed(sequenceNumb_mod5(39 downto 32)) * signed(mod5(39 downto 32)), sum'length)
                + resize(signed(sequenceNumb_mod5(47 downto 40)) * signed(mod5(47 downto 40)), sum'length)
                + resize(signed(sequenceNumb_mod5(55 downto 48)) * signed(mod5(55 downto 48)), sum'length);
                
            -- la divisione relativo a 1/64 e 1/1024
            o_data_sum := o_data_sum + shift_right(sum,6);
            o_data_sum := o_data_sum + shift_right(sum,10);
                
            -- nel caso se sum è negativo allora per ogni shift abbiamo bisogno di +1 -> in totale +2
            if(to_integer(sum) < 0) then
                o_data_sum := o_data_sum + to_signed(2, o_data_sum'length);
            end if;
        end if;
            
        -- saturazione max/min
        if (to_integer(o_data_sum) < -128) then
            o_mem_data <= "10000000"; -- -128
        elsif (to_integer(o_data_sum) > 127) then
            o_mem_data <= "01111111"; -- +127
        else
            -- caso >-128 e < 127
            o_mem_data <= std_logic_vector (o_data_sum(7 downto 0));
        end if;
    end process;

end Behavioral;
