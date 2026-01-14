library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CryptoCore is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(31 downto 0);
        key : in STD_LOGIC_VECTOR(31 downto 0);
        data_out : out STD_LOGIC_VECTOR(31 downto 0);
        valid : out STD_LOGIC
    );
end CryptoCore;

architecture Behavioral of CryptoCore is
    signal temp_reg : unsigned(31 downto 0);
    signal counter : unsigned(3 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            temp_reg <= (others => '0');
            counter <= (others => '0');
            valid <= '0';
        elsif rising_edge(clk) then
            if counter < 10 then
                temp_reg <= unsigned(data_in) xor unsigned(key) rol to_integer(counter);
                counter <= counter + 1;
                valid <= '0';
            else
                data_out <= std_logic_vector(temp_reg);
                valid <= '1';
                counter <= (others => '0');
            end if;
        end if;
    end process;
end Behavioral;
