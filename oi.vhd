library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

entity smartLocker is
  port (
    clock, reset, config, add_user                      : in std_logic;
    pass                                                : in std_logic_vector (7 downto 0);
    valid_led, error_led, registered, isLogged, blocked : out std_logic;
    hex_display                                         : out std_logic_vector (6 downto 0)
  );
end smartLocker;

architecture Behavioral of smartLocker is
  -- Tipo para os arrays de senhas
  type senha_array is array (0 to 5) of std_logic_vector(7 downto 0);
  type users_senha_array is array (0 to 3) of std_logic_vector(7 downto 0);

  -- Array de senhas de administradores
  shared variable admin_senhas : senha_array := (
  "01010101", -- senha 1 (8 bits)
  "01100001", -- senha 2 (8 bits)
  "00000000",
  "00000000",
  "00000000",
  "00000000"
  );

  -- Estados do sistema
  type estado_type is (IDLE, CFG, VERIFY_ADMIN, VERIFY_PASS, SUCCESS, ERROR, ADD_USR, REMOVE_USER, BLK);
  signal estado_atual, estado_proximo : estado_type;

  signal invalid_attempts : integer := 0; -- Contador de tentativas inválidas consecutivas
  signal block_timer      : integer := 0; -- Contador para o bloqueio de 5 ciclos de clock
  signal is_blocked       : boolean := false; -- Indica se o sistema está bloqueado

  signal match_found : boolean := false;
  signal admin_match : boolean := false;

  -- Tabela de decodificação para o display de 7 segmentos
  function decode_to_7seg(value : integer range 0 to 9) return std_logic_vector is
  begin
    case value is
      when 0      => return "1000000"; -- Exibe '0'
      when 1      => return "1111001"; -- Exibe '1'
      when 2      => return "0100100"; -- Exibe '2'
      when 3      => return "0110000"; -- Exibe '3'
      when 4      => return "0011001"; -- Exibe '4'
      when 5      => return "0010010"; -- Exibe '5'
      when 6      => return "0000010"; -- Exibe '6'
      when 7      => return "1111000"; -- Exibe '7'
      when 8      => return "0000000"; -- Exibe '8'
      when 9      => return "1110111"; -- Exibe '9'  
      when others => return "1111111"; -- Desligado
    end case;
  end function;

  -- Função para mapear estados a í­ndices inteiros
  function estado_para_indice(estado : estado_type) return integer is
  begin
    case estado is
      when IDLE         => return 0;
      when VERIFY_PASS  => return 1;
      when SUCCESS      => return 2;
      when VERIFY_ADMIN => return 3;
      when CFG          => return 4;
      when ADD_USR      => return 5;
      when REMOVE_USER  => return 6;
      when ERROR        => return 7;
      when BLK          => return 8;
      when others       => return 0; -- Default
    end case;
  end function;

begin
  process (clock, reset)
  begin
    if rising_edge(clock) then
      if reset = '1' then
        estado_atual     <= IDLE;
        block_timer      <= 0;
        is_blocked       <= false;
        invalid_attempts <= 0;
      else
        -- Gerenciar bloqueio
        if is_blocked then
          if block_timer > 0 then
            block_timer <= block_timer - 1; -- Decrementa o contador
          else
            is_blocked <= false; -- Desbloqueia quando o contador atinge 0
          end if;
        end if;

        -- Atualizar contador de tentativas inválidas
        if estado_atual = VERIFY_PASS or estado_atual = VERIFY_ADMIN then
          if not is_blocked and estado_proximo = ERROR then
            invalid_attempts <= invalid_attempts + 1;
            if invalid_attempts = 3 then
              is_blocked  <= true;
              block_timer <= 5; -- Define o bloqueio
            end if;
          else
            invalid_attempts <= 0; -- Reseta em caso de sucesso
          end if;
        end if;

        estado_atual <= estado_proximo;
      end if;
    end if;
  end process;

  -- Processo combinacional completo
  process (clock, estado_atual, pass, config, add_user, is_blocked)
  begin
    match_found <= false; -- Resetar a cada ciclo
    admin_match <= false; -- Resetar a cada ciclo

    case estado_atual is
      when IDLE =>
        valid_led   <= '0';
        error_led   <= '0';
        registered  <= '0';
        isLogged    <= '0';
        blocked     <= '0';
        match_found <= false; -- Resetar a cada ciclo
        admin_match <= false; -- Resetar a cada ciclo
        if config = '1' then
          estado_proximo <= VERIFY_ADMIN;
        else
          estado_proximo <= VERIFY_PASS;
        end if;

      when VERIFY_PASS =>
        if is_blocked then
          estado_proximo <= BLK;
        else
          valid_led  <= '0';
          error_led  <= '0';
          registered <= '0';
          isLogged   <= '0';
          blocked    <= '0';
          -- Verificar senha
          for i in 0 to 5 loop
            if unsigned(pass) = unsigned(admin_senhas(i)) then
              match_found    <= true;
              valid_led      <= '1';
              estado_proximo <= SUCCESS;
              exit;
            end if;

            if i = 5 then
              -- Se nenhuma correspondência for encontrada
              if not match_found then
                estado_proximo <= ERROR;

              end if;
            end if;
          end loop;

        end if;

      when VERIFY_ADMIN =>
        if is_blocked then
          estado_proximo <= BLK;
        else
          -- Verificar senhas de administrador
          for i in 0 to 1 loop
            if unsigned(pass) = unsigned(admin_senhas(i)) then
              admin_match    <= true;
              estado_proximo <= CFG;
              error_led      <= '0';
              isLogged       <= '1';
              exit;
            end if;
            if i = 1 then
              if not admin_match then
                error_led      <= '1';
                isLogged       <= '0';
                estado_proximo <= ERROR;
              end if;
            end if;
          end loop;
        end if;

      when CFG =>
        valid_led  <= '0';
        error_led  <= '0';
        isLogged   <= '1';
        registered <= '0';
        blocked    <= '0';
        if add_user = '1' then
          estado_proximo <= ADD_USR;
        else
          estado_proximo <= REMOVE_USER;
        end if;

      when ADD_USR =>
        valid_led <= '0';
        error_led <= '0';

        -- Adicionar usuário
        for i in 0 to 5 loop
          if admin_senhas(i) = "00000000" then
            admin_senhas(i) := pass;
            registered     <= '1';
            estado_proximo <= SUCCESS;
            exit;
          end if;
        end loop;
      when REMOVE_USER =>
        valid_led <= '0';
        error_led <= '0';

        -- Remover usuário
        for i in 0 to 5 loop
          if admin_senhas(i) = pass then
            admin_senhas(i) := "00000000";
            valid_led      <= '1';
            estado_proximo <= SUCCESS;
            exit;
          end if;
        end loop;
      when ERROR =>
        valid_led      <= '0';
        error_led      <= '1';
        registered     <= '0';
        blocked        <= '0';
        isLogged       <= '0';
        estado_proximo <= IDLE;

      when SUCCESS =>
        valid_led      <= '1';
        error_led      <= '0';
        registered     <= '0';
        isLogged       <= '0';
        blocked        <= '0';
        estado_proximo <= IDLE;

      when BLK =>
        valid_led  <= '0';
        error_led  <= '1';
        blocked    <= '1';
        registered <= '0';
        isLogged   <= '0';
        if not is_blocked then
          estado_proximo <= IDLE;
        else
          estado_proximo <= BLK;
        end if;

      when others =>
        estado_proximo <= IDLE;
    end case;
  end process;
  hex_display <= decode_to_7seg(estado_para_indice(estado_atual));

end Behavioral;