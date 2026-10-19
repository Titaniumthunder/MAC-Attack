# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "MAXD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "P" -parent ${Page_0}


}

proc update_PARAM_VALUE.MAXD { PARAM_VALUE.MAXD } {
	# Procedure called to update MAXD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAXD { PARAM_VALUE.MAXD } {
	# Procedure called to validate MAXD
	return true
}

proc update_PARAM_VALUE.P { PARAM_VALUE.P } {
	# Procedure called to update P when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P { PARAM_VALUE.P } {
	# Procedure called to validate P
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

