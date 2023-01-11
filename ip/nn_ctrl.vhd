----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2021 12:17:41 PM
-- Design Name: 
-- Module Name: nn_ctrl - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nn_ctrl is
    Port (  i_Clk : in STD_LOGIC;
    
            ap_ready : in STD_LOGIC;
            ap_start : out STD_LOGIC;
            ap_done  : in std_logic;
            ap_idle  : in std_logic;
            ap_rst   : out std_logic;
            
            
            rstb_busy: in std_logic;
            
            out_addres : out std_logic_vector(31 downto 0);
            out_din    : out std_logic_vector(31 downto 0); 
            out_dout   : in std_logic_vector(31 downto 0);
            out_we     : out std_logic_vector(3 downto 0);
            out_enb    : out std_logic := '1';
            out_rst    : out std_logic;
            
            nn_int_add : in std_logic_vector(31 downto 0);
            inp_addres : out std_logic_vector(31 downto 0);
            inp_din    : out std_logic_vector(31 downto 0); 
            --inp_dout   : in std_logic_vector(31 downto 0);
            inp_we     : out std_logic_vector(3 downto 0) :=(others => '0');
            inp_enb    : out std_logic := '1';
            inp_rst    : out std_logic;
            
            prediction : in std_logic_vector(31 downto 0)
           );
end nn_ctrl;

architecture Behavioral of nn_ctrl is

    signal state : integer range 0 to 2 := 0; -- our 3 states
begin

    ------------------  Start NN  ------------------
    PROCESS(i_Clk, ap_ready)  --The two process we are looking for is the ap_ready and i_Clk
    BEGIN
        case state is
            when 0 => --Wait for data state
                out_addres <= (others => '0'); --Set address
                out_we <= (others => '0'); --Read only
                if out_dout(0) = '1' then
                    ap_start <= '0';
                    
                    state <= 1;
                end if;
            when 1 => -- Process the data wait until done
                out_addres(2) <= '1'; --Set address for the prediction
                out_we <= (others => '1'); --Read only
                inp_addres <= nn_int_add;
                if ap_ready = '0' then
                    out_din <= prediction; --set the prediction saved in the right address (hopefully)
                    state <= 2;
                end if;
            when 2 => --Reset and get every thing done state
                out_addres(2) <= '0'; --Set address for the prediction
                out_we <= (others => '0'); --Read only
                
                state <= 0;
            end case;
    END PROCESS;
    
end Behavioral;
