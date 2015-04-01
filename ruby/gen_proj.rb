

## So right
def outs(*a)
	puts *a
end

outs "cmake_minimum_required(VERSION 2.8)"
outs "project(coremodel)"
outs "add_subdirectory(external/lua-5.1.4)"
outs ""

proj_root = "dscore"
target_name = "dscore"

# Find all the directories
Dir.glob("#{proj_root}/**/") do |path|
	#puts path
	a = path.split('/')
	src_name = 'SRC_'
	src_name += a.join('_').upcase
	a.shift
	for suf in ['.h', '.c', '.cc' , '.cpp', '.cxx'] do
		outs "file(GLOB #{src_name} \"#{path}*#{suf}\")"
		# outs "if(#{src_name})"
			if a.length > 0 then
				group_name = a.join("\\\\")
				# puts src_name
				outs "source_group(#{group_name} FILES ${#{src_name}})"
			end
			outs "set(FULL_SRC_LIST ${FULL_SRC_LIST} ${#{src_name}})"
		# outs "endif()"
		outs ""
	end
	# puts File.basename(path)
end

outs "include_directories(\"./#{proj_root}/legacy\")"
outs "include_directories(\"./external/lua-5.1.4/src\")"
outs "add_executable(#{target_name} ${FULL_SRC_LIST})"
outs "target_link_libraries(#{target_name} lua51)"



