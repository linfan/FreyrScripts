import os,re
import datetime

class_info_list = []
print_line_feed = '\n' #'\r\n'
ignore_dir_list = ['lost\+found', 'test', 'testcases', 'simulator', 'example']

class class_info:
    '''
    a structure use for store information of classes
    '''
    def __init__(self,name,file,super_classes,sub_classes,member_objects):
        self.local_in_file = file
        self.class_name = name
        self.super_class_list = super_classes
        self.sub_class_list = sub_classes
        self.member_object_list = member_objects
        self.is_base_class_node = True
        self.is_top_member_node = True
    def __repr__(self):
        global print_line_feed
        return 'Class Name :    '+self.class_name+print_line_feed+\
               'File Name :     '+self.local_in_file+print_line_feed+\
               'Super Classes : '+str(self.super_class_list)+print_line_feed+\
               'sub Classes :   '+str(self.sub_class_list)+print_line_feed+\
               'member objects :'+str(self.member_object_list)+(print_line_feed*2)


def find_local_file_by_class_name(a_class_name):
    '''
    find the file name contain the specified class name
    '''
    global class_info_list
    for class_info_index in range(len(class_info_list)):
        if class_info_list[class_info_index].class_name == a_class_name:
            return class_info_list[class_info_index].local_in_file
    return 'no-under-search-path'
        
    
def mark_sub_class(super_class_name,sub_class_name):
    '''
    append sub class to parent class's sub_class_list
    '''
    global class_info_list
    for class_info_index in range(len(class_info_list)):
        if class_info_list[class_info_index].class_name == super_class_name:
            class_info_list[class_info_index].sub_class_list.append(sub_class_name)

def mark_member_object(member_class_name):
    '''
    mark whether a class is contained by another class as a member object
    '''
    global class_info_list
    for class_info_node in class_info_list:
        if class_info_node.class_name == member_class_name:
            class_info_node.is_top_member_node = False

def test_base_class(base_class_list,sub_class_name):
    '''
    test if a specified base class is under search path
    '''
    global class_info_list
    for base_class_name in base_class_list:
        is_base_class_exist = False
        for class_info_node in class_info_list:
            if class_info_node.class_name == base_class_name:
                is_base_class_exist = True
                break
        if not is_base_class_exist:
            class_info_list.append(class_info(base_class_name,'no-under-search-path',[],[sub_class_name],[]))

def print_inherit_tree(top_class_name,tab_num,node_name_list,inherit_tree_file_content):
    '''
    print inherit tree to text file
    '''
    global class_info_list,print_line_feed
    longest_inherit_chain = 10
    if top_class_name in node_name_list:
        return
    if tab_num > longest_inherit_chain:
        print_str = ' '*((tab_num-1)*3+1)+'.. too long inherit chain '
        ##inherit_tree_file.write(print_str+print_line_feed)
        inherit_tree_file_content.append(print_str+print_line_feed)
        return
    node_name_list.append(top_class_name)
    #find specified file, not must, can be time consuming
    file_contain_the_class = find_local_file_by_class_name(top_class_name)
    print_str = (tab_num == 0) and (print_line_feed+top_class_name) or (' '*((tab_num-1)*3+1)+'|_ '+top_class_name)
    print_str += '      ('+file_contain_the_class+')'
    ##print print_str
    ##inherit_tree_file.write(print_str+print_line_feed)
    inherit_tree_file_content.append(print_str+print_line_feed)
    for class_info_node in class_info_list:
        if class_info_node.class_name == top_class_name:
            if not class_info_node.sub_class_list: # == []
                return
            else:
                for sub_class_name in class_info_node.sub_class_list:
                    print_inherit_tree(sub_class_name,tab_num+1,node_name_list,inherit_tree_file_content)

def print_member_tree(top_member_name,tab_num,node_name_list,member_tree_file_content):
    '''
    print member tree to text file
    '''
    global class_info_list,print_line_feed
    longest_member_chain = 10
    if top_member_name in node_name_list:
        print_str = ' '*((tab_num-1)*3+1)+'|_ {'+top_member_name+'}'
        ##member_tree_file.write(print_str+print_line_feed)
        member_tree_file_content.append(print_str+print_line_feed)
        return
    if tab_num > longest_member_chain:
        print_str = ' '*((tab_num-1)*3+1)+'.. too long member chain '
        ##member_tree_file.write(print_str+print_line_feed)
        member_tree_file_content.append(print_str+print_line_feed)
        return
    node_name_list.append(top_member_name)
    # find specified file, not must, can be time consuming
    file_contain_the_class = find_local_file_by_class_name(top_member_name)
    print_str = (tab_num == 0) and (print_line_feed+top_member_name) or (' '*((tab_num-1)*3+1)+'|_ '+top_member_name)
    print_str += '      ('+file_contain_the_class+')'
    ##print print_str
    ##member_tree_file.write(print_str+print_line_feed)
    member_tree_file_content.append(print_str+print_line_feed)
    for class_info_node in class_info_list:
        if class_info_node.class_name == top_member_name:
            if not class_info_node.member_object_list: # == []
                return
            else:
                for member_object_name in class_info_node.member_object_list:
                    print_member_tree(member_object_name,tab_num+1,node_name_list,member_tree_file_content)
    
def print_class_info(class_info_node,print_no_exist_file,class_info_file_content):
    '''
    print class information to text file
    '''
    if not print_no_exist_file:
        if class_info_node.local_in_file == 'no-under-search-path':
            return
    ##print class_info_node
    ##class_info_file.write(class_info_node.__repr__())
    class_info_file_content.append(class_info_node.__repr__())

def is_find_in_str(str,pattem):
    '''
    use this function instead of str.find
    '''
    if str.find(pattem) == -1:
        return False
    else:
        return True

def remove_comment(one_line,is_in_comment):
    '''
    remove comments in code
    '''
    if is_in_comment:
        if is_find_in_str(one_line,r'*/'):
            one_line = one_line.split(r'*/')[1]
            is_in_comment = False
        else:
            one_line = ''
    if is_find_in_str(one_line,r'/*'):
        if is_find_in_str(one_line,r'*/'):
            one_line = one_line.split(r'/*')[0] + one_line.split(r'*/')[-1]
        else:
            one_line = one_line.split(r'/*')[0]
            is_in_comment = True
    if is_find_in_str(one_line,r'//'):
        one_line = one_line.split(r'//')[0]
    one_line = one_line.rstrip(' \t\\') # ignore last backslash and blank
    return one_line,is_in_comment

def recurse_path_with_link_following(path_to_follow, file_list, recurse_depth):
    '''
    To avoid infinite recursive loop, must limit the recursive depth
    '''
    if recurse_depth > 3:
        print('>> path ' + path_to_follow + ' depth > 3, return')
        return
    print('>> path ' + path_to_follow + ' followed')
    for dir_path,dir_names,file_names in os.walk(path_to_follow):
        ignore_dir = False
        for dir in ignore_dir_list: # ignore dir wtih specific suffix
            if re.match('.*' + dir, dir_path):
                print('>> path ' + dir_path + ' ignore')
                ignore_dir = True
                break
        if ignore_dir == True:
            dir_names[:] = [] # ignore sub dirs
            continue
        for dir in dir_names:
            if os.path.islink(dir_path+os.sep+dir):
                recurse_path_with_link_following(dir_path+os.sep+dir, file_list, recurse_depth + 1)
        for file in file_names:
            if re.match('.+\.(h|hpp|hh)$',file):
                file_list.append(dir_path+os.sep+file)    

def analyze_directory(directory_to_analyze,inherit_tree_file_name,member_tree_file_name,class_info_file_name):
    '''
    analyze a specified directory, generate structure file
    '''
    global class_info_list
    start_time = datetime.datetime.now()
    print('searching files in current directory ..')
    search_dir = os.path.abspath(directory_to_analyze)
    file_list = []
    recurse_path_with_link_following(search_dir, file_list, 0)
    print('begin analyze files ..')
    class_info_index = -1
    class_name_list = []
    for file in file_list:
        if os.path.exists(file) == False:
            print('>> file ' + file + ' missing')
            continue
        try:
            file_obj = open(file)
        except IOError:
            print('>> file ' + file + ' cannot open')
            continue
        print('>> analyzing file: ' + file)
        content_lines = file_obj.readlines()
        file_obj.close()
        line_length = len(content_lines)
        line_index = -1
        is_in_comment = False
        while line_index < line_length-1:
            line_index += 1
            one_line = content_lines[line_index]
            one_line,is_in_comment = remove_comment(one_line,is_in_comment)
            if one_line == '': # the line is totally commented
                continue
            if re.match('^[ \t]*class[ \t]+[a-zA-Z0-9:_]+[^;]*$',one_line):
                ##print '[--'+line
                if is_find_in_str(one_line,'template'):
                    continue
                tmp_name = one_line.split(':')[0]
                if re.match(r'.*\{[ \t]*\\?[ \t]*$',tmp_name):
                    tmp_name = tmp_name.split('{')[0]
                tmp_name_list = tmp_name.split()
                if is_find_in_str(tmp_name_list[-1],r'>'):
                    while tmp_name_list and not is_find_in_str(tmp_name_list[0],r'<'):
                        del tmp_name_list[0]
                    if not tmp_name_list:
                        continue # source file error
                    else:
                        class_name = ''.join(tmp_name_list)
                else:
                    class_name = tmp_name_list[-1]
                # add new class name to list, ignore redundant class name
                if class_name in class_name_list:
                    continue
                else:
                    class_name_list.append(class_name)
                ##print class_name
                class_info_list.append(class_info(class_name,file,[],[],[]))
                class_info_index += 1
                # search super classes
                line_index -= 1
                reach_end = False
                while line_index<line_length-1:
                    line_index += 1
                    one_line = content_lines[line_index]
                    if is_find_in_str(one_line,r'{'):
                        one_line = one_line.split(r'{')[0]
                        reach_end = True
                    one_line,is_in_comment = remove_comment(one_line,is_in_comment)
                    if one_line == '': # the line is totally commented
                        continue
                    split_line_list = ' '.join(one_line.split(',')).split()
                    for key_word in ['public','protect','private']:
                        if key_word in split_line_list:
                            for split_line_index in range(len(split_line_list)-1):
                                if split_line_list[split_line_index] == key_word:
                                    class_info_list[class_info_index].super_class_list.append(split_line_list[split_line_index+1].rstrip(r','))
                    if reach_end:
                        break
                ##print class_info_list[class_info_index]
                # search member objects
                while line_index<line_length-1:
                    line_index += 1
                    one_line = content_lines[line_index]
                    one_line,is_in_comment = remove_comment(one_line,is_in_comment)
                    if one_line == '': # the line is totally commented
                        continue
                    if not is_find_in_str(one_line,r')') \
                        and is_find_in_str(one_line,r';') \
                        and not re.match('[ \t]*//]',one_line):
                        # another interesting code
                        try:
                            member_object_name = one_line.split(';')[0].split(',')[0].split()[-2].rstrip(r'&*')
                        except IndexError:
                            pass
                        else:
                            # suppose all class name begin with capital letter
                            if member_object_name != '' and member_object_name[0].isupper():
                                class_info_list[class_info_index].member_object_list.append(member_object_name)
                    if is_find_in_str(one_line,r'};'):
                        break
                ##print class_info_list[class_info_index]
    print('analysis finished, begin build tree structure ..')
    # analyze tree structure
    for class_info_node in class_info_list:
        if class_info_node.super_class_list: # != []
            class_info_node.is_base_class_node = False
            test_base_class(class_info_node.super_class_list,class_info_node.class_name)
        # analyze sub-class relation
        for super_class_name in class_info_node.super_class_list:
            mark_sub_class(super_class_name,class_info_node.class_name)
        # remove redundant items in sub_class_list
        if class_info_node.sub_class_list: # != []
            tmp_sub_class_list = []
            for sub_class_index in range(len(class_info_node.sub_class_list)):
               if (class_info_node.sub_class_list[sub_class_index] != class_info_node.class_name) \
                  and (not class_info_node.sub_class_list[sub_class_index] in tmp_sub_class_list):
                   tmp_sub_class_list.append(class_info_node.sub_class_list[sub_class_index])
            class_info_node.sub_class_list = tmp_sub_class_list
        # analyze member object relation
        for member_object_name in class_info_node.member_object_list:
            mark_member_object(member_object_name)
        # remove redundant items in member_object_list
        if class_info_node.member_object_list: # != []
            tmp_member_object_list = []
            for member_object_index in range(len(class_info_node.member_object_list)):
               if (class_info_node.member_object_list[member_object_index] != class_info_node.class_name) \
                  and (not class_info_node.member_object_list[member_object_index] in tmp_member_object_list):
                   tmp_member_object_list.append(class_info_node.member_object_list[member_object_index])
            class_info_node.member_object_list = tmp_member_object_list
        ##print class_info_node
    # display results
    inherit_tree_file_content = []
    member_tree_file_content = []
    class_info_file_content = []
    for class_info_node in class_info_list:
        if class_info_node.is_base_class_node:
            print_inherit_tree(class_info_node.class_name,0,[],inherit_tree_file_content)
            ##print 'base-class >> '+class_info_node.class_name
        if class_info_node.is_top_member_node:
            print_member_tree(class_info_node.class_name,0,[],member_tree_file_content)
            ##print('top-member >> '+class_info_node.class_name)
        print_class_info(class_info_node,True,class_info_file_content)
    end_time = datetime.datetime.now()
    print('writing files ..')
    inherit_tree_file = open(inherit_tree_file_name,'w')
    member_tree_file = open(member_tree_file_name,'w')
    class_info_file = open(class_info_file_name,'w')
    inherit_tree_file.writelines(inherit_tree_file_content)
    member_tree_file.writelines(member_tree_file_content)
    class_info_file.writelines(class_info_file_content)
    inherit_tree_file.close()
    member_tree_file.close()
    class_info_file.close()
    print('done !')
    print('inherit tree file is stored at : '+inherit_tree_file.name)
    print('member tree file is stored at :   '+member_tree_file.name)
    print('class info file is stored at :    '+class_info_file.name)
    print('Total Time Cause : '+str((end_time - start_time).seconds)+' seconds')

    os.system('pause')

__author__  = 'linfan'
__date__    = '$2011-07-18 12:40:00$'
__version__ = '1.3.3'
if __name__ == '__main__':
    analyze_directory(os.curdir,'inherit_tree_file.txt','member_tree_file.txt','class_info_file.txt')

'''
== Change log ==

version 1.3.4
date 2013-05-13
    Update to python 3.x syntax

version 1.3.3
date 2012-07-18
    Add exception handler to skip invalid link files when analizing

version 1.3.2
date 2012-07-17
    Add ignore path recognition

version 1.3.1
date 2012-07-16
    Add recurse_path_with_link_following function, fix bug search can't follow link file in Linux.

version 1.3.0
date 2011-04-10
    Stable version release.

================
'''
    
