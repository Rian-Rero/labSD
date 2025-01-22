library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DigitalLock is
    Port (
        clk        : in  STD_LOGIC;              -- Clock
        reset      : in  STD_LOGIC;              -- Reset
        input_pwd  : in  STD_LOGIC_VECTOR(7 downto 0); -- Input password
        is_admin   : out STD_LOGIC;              -- Indicates if admin access
        is_user    : out STD_LOGIC;              -- Indicates if user access
        lock_open  : out STD_LOGIC;              -- Indicates lock is open
        admin_add  : in  STD_LOGIC;              -- Admin adds new password
        admin_del  : in  STD_LOGIC;              -- Admin deletes a password
        action_done: out STD_LOGIC               -- Indicates action is completed
    );
end DigitalLock;

architecture Behavioral of DigitalLock is
    -- Hard-coded admin passwords
    constant ADMIN_PWD1 : STD_LOGIC_VECTOR(7 downto 0) := "11011001"; -- Admin password 1
    constant ADMIN_PWD2 : STD_LOGIC_VECTOR(7 downto 0) := "10110101"; -- Admin password 2

    -- Memory for user passwords (4 slots)
    signal user_pwds : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal user_count : INTEGER range 0 to 4 := 0; -- Track number of user passwords

    -- Internal signals
    signal valid_admin : STD_LOGIC := '0';
    signal valid_user  : STD_LOGIC := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset the system
            valid_admin <= '0';
            valid_user <= '0';
            lock_open <= '0';
            user_pwds <= (others => (others => '0'));
            user_count <= 0;
            action_done <= '0';
        elsif rising_edge(clk) then
            -- Check if input matches admin passwords
            if (input_pwd = ADMIN_PWD1 or input_pwd = ADMIN_PWD2) then
                valid_admin <= '1';
                valid_user <= '0';
                lock_open <= '1';
            -- Check if input matches any user password
            elsif input_pwd /= (others => '0') and input_pwd = user_pwds then
                valid_user <= '1';
                valid_admin <= '0';
                lock_open <= '1';
            else
                valid_user <= '0';
                valid_admin <= '0';
                lock_open <= '0';
            end if;

            -- Admin adding a password
            if admin_add = '1' and valid_admin = '1' and user_count < 4 then
                user_pwds(user_count) <= input_pwd;
                user_count <= user_count + 1;
                action_done <= '1';
            elsif admin_add = '1' and valid_admin = '0' then
                action_done <= '0'; -- Invalid action, not admin
            end if;

            -- Admin deleting a password
            if admin_del = '1' and valid_admin = '1' then
                user_pwds <= (others => (others => '0'));
                user_count <= 0;
                action_done <= '1';
            elsif admin_del = '1' and valid_admin = '0' then
                action_done <= '0'; -- Invalid action, not admin
            end if;
        end if;
    end process;

    -- Outputs
    is_admin <= valid_admin;
    is_user <= valid_user;

end Behavioral;
