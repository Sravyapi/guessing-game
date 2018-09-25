library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game is
Port (switch: in STD_LOGIC_VECTOR(15 downto 0);
LED: out STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
btnC,btnD,btnU,btnL,btnR: in std_logic;
an: out STD_LOGIC_VECTOR(3 downto 0);
seg: out STD_LOGIC_VECTOR(6 downto 0);
CLK100MHZ: in std_logic
);
end game;

architecture Behavioral of game is

signal switch0: std_logic_vector(3 downto 0);
signal TempBuffer: std_logic_vector(15 downto 0);
signal slowclock : STD_LOGIC;                                                                          
signal refresh_counter: std_logic_vector (16 downto 0);

function BinToHex (bin :in std_logic_vector(3 downto 0))--------Binary to hexadecimal converter
  return std_logic_vector is
    begin
    case (bin) is
              when "0000" => return "1000000"; -- "0"
              when "0001" => return "1111001"; -- "1"
              when "0010" => return "0100100"; -- "2"
              when "0011" => return "0110000"; -- "3"
              when "0100" => return "0011001"; -- "4"
              when "0101" => return "0010010"; -- "5"
              when "0110" => return "0000010"; -- "6"
              when "0111" => return "1111000"; -- "7"
              when "1000" => return "0000000"; -- "8"
              when "1001" => return "0010000"; -- "9"
              when "1010" => return "0001000"; -- "a"
              when "1011" => return "0000011"; -- "b"
              when "1100" => return "1000110"; -- "C"
              when "1101" => return "0100001"; -- "d"
              when "1110" => return "0000110"; -- "e"
              when "1111" => return "0001110"; -- "f"
              when others => return "0000000"; -- "e"
       end case;
end BinToHex;
begin

process(CLK100MHZ) -----Frequency divider
begin
if rising_edge(CLK100MHZ) then
   refresh_counter <= refresh_counter + '1';
end if;
end process;

slowclock <= refresh_counter(16);
switch0<=switch(3 downto 0);

process(slowclock)
variable status : integer:= -1;
variable current_player : integer:= 1;--- 1 corresponds to player 1, 2 to player 2, 3 - game over
variable counter,LEDcounter : integer:= 0;
variable greater,smaller : std_logic:= '0';
variable count,flag : integer:=0;
variable PL1Buffer,PL2Buffer,count_unsigned : std_logic_vector(15 downto 0):="0000000000000000";
variable D3,D2,D1,D0,F3,F2,F1,F0 : std_logic_vector(3 downto 0):="0000";
variable count0,count1,count2,count3 : std_logic_vector(3 downto 0);

begin
if rising_edge(slowclock) then
status:=status+1;------Game starts when status=0
LED<="0000000000000000";
counter:=counter+1;
LEDcounter:=LEDcounter+1;
if counter>=1000 then
  if current_player = 1 then----game is still on--player1 is playing
          LED<=switch;
            if btnR='1' then
               D0:=switch0;
               elsif btnD='1' then
               D1:=switch0;
               elsif btnU='1' then
               D2:=switch0;
               elsif btnL='1' then
               D3:=switch0;
               end if;
   elsif current_player = 2 then---player2 is playing
           LED<=switch;
            if btnR='1' then
               F0:=switch0;
               elsif btnD='1' then
               F1:=switch0;
               elsif btnU='1' then
               F2:=switch0;
               elsif btnL='1' then
               F3:=switch0;
               end if;
   elsif current_player = 3 then---correct guess.Game over!
          if LEDcounter>=250 then
                  LED<="1111111111111111";
                  LEDcounter:=0;
          end if;
  end if; -- current_player = 3 code ends
  if btnC = '1' then
         if current_player = 1 then
                 PL1Buffer:= D3 & D2 & D1 & D0 ;--concatenate the individual digits
                 counter:=0;
                 current_player:=current_player+1;--Player 2 takes the control
                 flag:=0;
         elsif current_player = 2 then
                 PL2Buffer:=  F3 & F2 & F1 & F0 ;
                 counter:=0;
                 current_player:=current_player+1;
                 flag:=0;
         end if; --current_player code ends
         if current_player = 3 then----when player 2 submits a guess
                 count:=count+1;--increase count for each attempt
                 if PL1Buffer = PL2Buffer then -- when operand 2 is equal to PL1Buffer then we wil brighten all LEDs and display number of guesses taken on seven segment display                        
                         greater:='0';
                         smaller:='0';
                         count_unsigned:=std_logic_vector(to_unsigned(count,count_unsigned'length));
                         count0:=count_unsigned(3 downto 0);
                         count1:=count_unsigned(7 downto 4);
                         count2:=count_unsigned(11 downto 8);
                         count3:=count_unsigned(15 downto 12);
                 elsif PL2Buffer > PL1Buffer then -- when PL2Buffer is greater than PL1Buffer then we wil display msg '2 HI' on seven segment display
                         greater:='1';
                         smaller:='0';
                         current_player:=2;--updating it back to 2 to continue the game
                 elsif PL2Buffer < PL1Buffer then -- when PL2Buffer is smaller than PL1Buffer then we wil display msg '2 LO' on seven segment display
                         smaller:='1';
                         greater:='0';
                         current_player:=2;
                 end if; -- equality check ends here
         end if;--current_player loop ends here
  end if; -- btnC = 1 code end
 end if; -- counter code ends
 if status = 0 then
 an<="1110";
          if flag = 1 then
                       if current_player=1 then
                          seg <= BinToHex(D0);
                       elsif current_player=2 then
                          seg <= BinToHex(F0);
                       end if;
          elsif flag = 0 then
                  if current_player = 1 then
                          seg <="1111001";  -- printing 1 on anode 0
                  elsif current_player = 2 and greater = '1' then
                          seg <="1111001"; --printing I on anode 0
                  elsif current_player = 2 and smaller = '1' then
                          seg <="1000000"; --printing O on anode 0
                  elsif current_player = 2 then
                          seg <="0100100";  -- printing 2 on anode 0
                  elsif current_player = 3 then
                         seg <= BinToHex(count0);---print no. of guesses
                  end if;
          end if; -- flag code ends
 elsif status = 1 then
          if flag = 1 then
                  an<="1101";
                       if current_player=1 then
                       seg <= BinToHex(D1);
                       elsif current_player=2 then
                       seg <= BinToHex(F1);
                       end if;
          elsif flag = 0 then
                  if current_player = 1 then
                          an<="1111"; -- printing nothing on this anode
                  elsif current_player = 2 and greater = '1' then
                          an<="1101";
                          seg<="0001001"; -- printing H on anode 1
                  elsif current_player = 2 and smaller ='1' then
                          an<="1101";
                          seg<="1000111"; -- printing L on anode 1
                  elsif current_player= 2 then
                          an<="1111"; -- printing nothing on this anode
                  elsif current_player = 3 then
                          an<="1101";
                           seg <= BinToHex(count1);
                  end if;
          end if; -- flag code ends
 elsif status = 2 then
          if flag = 1 then
                  an<="1011";
                           if current_player=1 then
                               seg <= BinToHex(D2);
                           elsif current_player=2 then
                               seg <= BinToHex(F2);
                           end if;
          elsif flag = 0 then
                  if current_player = 1 then
                          an<="1011";
                          seg<="1000111"; -- printing L on anode 2
                  elsif current_player = 2 and greater = '1' then
                          an<="1111"; -- printing nothing on this anode
                  elsif current_player = 2 and smaller = '1' then
                          an<="1111"; -- printing nothing on this anode
                  elsif current_player = 2 then
                          an<="1011";
                          seg<="1000111"; -- printing L on anode 2
                  elsif current_player = 3 then
                          an<="1011";
                          seg <= BinToHex(count2);
                  end if;
          end if; --flag code ends
 elsif status = 3 then
         if flag = 1 then
          an<="0111";
                       if current_player=1 then
                       seg <= BinToHex(D3);
                       elsif current_player=2 then
                       seg <= BinToHex(F3);
                       end if;
         elsif flag = 0 then
                 if current_player = 1 then
                          an<="0111";
                          seg<="0001100"; -- printing P on anode 3
                 elsif current_player = 2 and greater = '1' then
                          an<="0111";
                          seg<="0100100";  -- printing 2 on anode 3
                 elsif current_player = 2 and smaller = '1' then
                          an<="0111";
                          seg<="0100100";  -- printing 2 on anode 3
                 elsif current_player = 2 then
                          an<="0111";
                          seg<="0001100"; -- printing P on anode 3
                 elsif current_player = 3 then
                          an<="0111";
                          seg <= BinToHex(count3);
                 end if;
         end if; -- flag code ends
       status:=-1;
  end if; -- status code ends
end if; -- rising edge ends
if TempBuffer /= switch then--when input on switches changes, update temp buffer and flag
TempBuffer<=switch;
flag:=1;
end if;
end process;
end Behavioral;