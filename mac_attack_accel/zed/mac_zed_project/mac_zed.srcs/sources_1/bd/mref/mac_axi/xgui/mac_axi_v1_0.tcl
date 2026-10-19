# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CORE_CLK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "EXACT_ACC" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAXD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MEM_REG" -parent ${Page_0}
  ipgui::add_param $IPINST -name "P" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PE_PRIM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PIPE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CORE_CLK { PARAM_VALUE.CORE_CLK } {
	# Procedure called to update CORE_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CORE_CLK { PARAM_VALUE.CORE_CLK } {
	# Procedure called to validate CORE_CLK
	return true
}

proc update_PARAM_VALUE.EXACT_ACC { PARAM_VALUE.EXACT_ACC } {
	# Procedure called to update EXACT_ACC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EXACT_ACC { PARAM_VALUE.EXACT_ACC } {
	# Procedure called to validate EXACT_ACC
	return true
}

proc update_PARAM_VALUE.MAXD { PARAM_VALUE.MAXD } {
	# Procedure called to update MAXD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAXD { PARAM_VALUE.MAXD } {
	# Procedure called to validate MAXD
	return true
}

proc update_PARAM_VALUE.MEM_REG { PARAM_VALUE.MEM_REG } {
	# Procedure called to update MEM_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MEM_REG { PARAM_VALUE.MEM_REG } {
	# Procedure called to validate MEM_REG
	return true
}

proc update_PARAM_VALUE.P { PARAM_VALUE.P } {
	# Procedure called to update P when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P { PARAM_VALUE.P } {
	# Procedure called to validate P
	return true
}

proc update_PARAM_VALUE.PE_PRIM { PARAM_VALUE.PE_PRIM } {
	# Procedure called to update PE_PRIM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PE_PRIM { PARAM_VALUE.PE_PRIM } {
	# Procedure called to validate PE_PRIM
	return true
}

proc update_PARAM_VALUE.PIPE { PARAM_VALUE.PIPE } {
	# Procedure called to update PIPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PIPE { PARAM_VALUE.PIPE } {
	# Procedure called to validate PIPE
	return true
}


proc update_MODELPARAM_VALUE.P { MODELPARAM_VALUE.P PARAM_VALUE.P } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.P}] ${MODELPARAM_VALUE.P}
}

proc update_MODELPARAM_VALUE.MAXD { MODELPARAM_VALUE.MAXD PARAM_VALUE.MAXD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAXD}] ${MODELPARAM_VALUE.MAXD}
}

proc update_MODELPARAM_VALUE.PIPE { MODELPARAM_VALUE.PIPE PARAM_VALUE.PIPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PIPE}] ${MODELPARAM_VALUE.PIPE}
}

proc update_MODELPARAM_VALUE.MEM_REG { MODELPARAM_VALUE.MEM_REG PARAM_VALUE.MEM_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MEM_REG}] ${MODELPARAM_VALUE.MEM_REG}
}

proc update_MODELPARAM_VALUE.EXACT_ACC { MODELPARAM_VALUE.EXACT_ACC PARAM_VALUE.EXACT_ACC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EXACT_ACC}] ${MODELPARAM_VALUE.EXACT_ACC}
}

proc update_MODELPARAM_VALUE.CORE_CLK { MODELPARAM_VALUE.CORE_CLK PARAM_VALUE.CORE_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CORE_CLK}] ${MODELPARAM_VALUE.CORE_CLK}
}

proc update_MODELPARAM_VALUE.PE_PRIM { MODELPARAM_VALUE.PE_PRIM PARAM_VALUE.PE_PRIM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PE_PRIM}] ${MODELPARAM_VALUE.PE_PRIM}
}

