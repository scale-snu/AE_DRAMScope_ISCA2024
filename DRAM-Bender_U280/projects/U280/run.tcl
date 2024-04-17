open_project ./U280.xpr
update_compile_order -fileset sources_1
reset_run synth_1
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 16
#close_project ./U280.xpr
