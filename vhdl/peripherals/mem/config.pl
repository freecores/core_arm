#!/usr/bin/perl

%peri_mem_cfg = (
    
# Memory controller config
    
    CONFIG_MCTRL_8BIT => 0,
    CONFIG_MCTRL_16BIT => 0,
    CONFIG_MCTRL_5CS => 0,
    CONFIG_MCTRL_WFB => 0,
    CONFIG_MCTRL_SDRAM => 0,
    CONFIG_MCTRL_SDRAM_INVCLK => 0,

    # Boot 
    CFG_BOOT_SOURCE =>  "perimem_memory",
    CONFIG_BOOT_RWS =>  0,
    CONFIG_BOOT_WWS =>  0,
    CONFIG_BOOT_SYSCLK =>  25000000,
    CONFIG_BOOT_BAUDRATE =>  19200,
    CONFIG_BOOT_EXTBAUD =>  0,
    CONFIG_BOOT_PROMABITS =>  11,

    # Peripherals 
    CONFIG_PERI_WPROT => 0
    
);

%peri_mem_map = 
   (
     # Memory controller 
    CONFIG_MCTRL_8BIT => [CONFIG_MCTRL_8BIT => 1],
    CONFIG_MCTRL_16BIT => [CONFIG_MCTRL_16BIT => 1],
    CONFIG_MCTRL_5CS => [CONFIG_MCTRL_5CS => 1],
    CONFIG_MCTRL_WFB => [CONFIG_MCTRL_WFB => 1],
    CONFIG_MCTRL_SDRAM => [CONFIG_MCTRL_SDRAM => 1],
    CONFIG_MCTRL_SDRAM_INVCLK => [CONFIG_MCTRL_SDRAM_INVCLK => 1],

    # Boot 
    CFG_BOOT_SOURCE => [
	CONFIG_BOOT_EXTPROM => "perimem_memory",
	CONFIG_BOOT_INTPROM => "perimem_prom",
	CONFIG_BOOT_MIXPROM => "perimem_dual" 
	],
    
    CONFIG_BOOT_RWS => [CONFIG_BOOT_RWS => sub { my ($v) = @_; $v = hex ($v) & 0x3;  return $v;} ],
    CONFIG_BOOT_WWS => [CONFIG_BOOT_WWS => sub { my ($v) = @_; $v = hex ($v) & 0x3;  return $v;} ],
    CONFIG_BOOT_SYSCLK => [CONFIG_BOOT_SYSCLK => sub { my ($v) = @_; return $v;} ],
    CONFIG_BOOT_BAUDRATE => [CONFIG_BOOT_BAUDRATE => sub { my ($v) = @_; $v = hex ($v) & 0x3fffff;  return $v;} ],
    CONFIG_BOOT_EXTBAUD => [CONFIG_BOOT_EXTBAUD => 1],
    CONFIG_BOOT_PROMABITS => [CONFIG_BOOT_PROMABITS => sub { my ($v) = @_; $v = hex ($v) & 0x3f;  return $v;} ],
 
    # Peripherals 
    CONFIG_PERI_WPROT => [CONFIG_PERI_WPROT => 1]
    
);		     

sub peri_mem_config_file {
    
    my ($pericfg) = @_;
    my %pericfg = %{$pericfg};
    my $fn = "vhdl/peripherals/mem/peri_mem_config.vhd";
    
    if (-f $fn) {
	print STDERR ("Making backup of $fn\n");
	`cp $fn $fn.bck`;
    }
    
    foreach $k (keys %pericfg) {
	$v = $pericfg{$k};
	$peri_mem_config_file_data = cfg_replace ($k,$v,$peri_mem_config_file_data);
    }

    if (open(FILEH, ">$fn")) {
	print FILEH $peri_mem_config_file_data;
    } else {
	die ("opening \"$fn\": $!\n");
    }
}

$peri_mem_config_file_data=<<PERI_MEM_CONFIG_END;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

package peri_mem_config is

-----------------------------------------------------------------------------
-- Automatically generated by vhdl/peripherals/mem/config.pl from of .config
-----------------------------------------------------------------------------

constant CFG_PERIMEM_BUS8EN : boolean := %CONFIG_MCTRL_8BIT%[b]; -- enable 8-bit bus operation
constant CFG_PERIMEM_BUS16EN : boolean := %CONFIG_MCTRL_16BIT%[b]; -- enable 16-bit bus operation
constant CFG_PERIMEM_WENDFB : boolean := %CONFIG_MCTRL_WFB%[b]; -- enable wen feed-back to data bus drivers
constant CFG_PERIMEM_RAMSEL5 : boolean := %CONFIG_MCTRL_5CS%[b]; -- enable 5th ram select
constant CFG_PERIMEM_SDRAMEN : boolean := %CONFIG_MCTRL_SDRAM%[b]; -- enable sdram controller
constant CFG_PERIMEM_SDINVCLK : boolean := %CONFIG_MCTRL_SDRAM_INVCLK%[b]; -- invert sdram clock

type cfg_perimem_boottype is (perimem_memory, perimem_prom, perimem_dual);

constant CFG_PERIMEM_BOOT :  cfg_perimem_boottype := %CFG_BOOT_SOURCE%; -- select boot source
constant CFG_PERIMEM_BRAMRWS   	: unsigned(3 downto 0) := conv_unsigned(%CONFIG_BOOT_RWS%, 4);	-- ram read waitstates
constant CFG_PERIMEM_BRAMWWS   	: unsigned(3 downto 0) := conv_unsigned(%CONFIG_BOOT_WWS%, 4);	-- ram write waitstates
constant CFG_PERIMEM_SYSCLK   	: integer := %CONFIG_BOOT_SYSCLK%;	-- cpu clock
constant CFG_PERIMEM_BAUD     	: positive := %CONFIG_BOOT_BAUDRATE%;	-- UART baud rate
constant CFG_PERIMEM_EXTBAUD  	: boolean := %CONFIG_BOOT_EXTBAUD%[b];	-- use external baud rate setting
constant CFG_PERIMEM_PABITS   	: positive := %CONFIG_BOOT_PROMABITS%;	-- internal boot-prom address bits

constant CFG_PERIMEM_WPROTEN   	: boolean := %CONFIG_PERI_WPROT%[b]; -- enable RAM write-protection unit

-----------------------------------------------------------------------------
-- end of automatic configuration
-----------------------------------------------------------------------------

end peri_mem_config;

PERI_MEM_CONFIG_END

1;












