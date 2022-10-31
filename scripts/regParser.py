'''
    Register Parser  - Register Parser parses a xlsx file with register definitions in order
                       to produce a C or ANSI header file with all the register definitions.

    Author: Sakis Panou <sakis.panou@gmail.com>
'''
import argparse
import sys
import os.path
import pathlib


def getDescriptionLines(description, lineLength=100):
    '''
        getDescriptionLines(description, lineLength)

        Description: Creates an array of strings for each carriage return.

        Parameters:
            o - description -> The description column in a string
            o - lineLength -> Specifies the maximum line length, default 100

        Returns:
            On success a list of lines, each line will be formatted to fit
            maximum length specified by the lineLength parameter. Otherwise
            it will return an None.
    '''
    originalLines = description.split("\n")
    formattedLines = formatDescriptionLines(originalLines, lineLength)

    return(formattedLines)

def formatDescriptionLines(lines, lineLength = 100):
    '''
        formatDescriptionLines(lines, lineLength)

        Description: Creates an array of strings each with a max length of lineLength.

        Parameters:
            o - lines -> A list of unformatted strings
            o - lineLength -> Specifies the maximum line length, default 100

        Returns:
            On success a list of lines, each line will be formatted to fit
            maximum length specified by the lineLength parameter. Otherwise
            it will return an None.
    '''
    newLines = []

    # Walk through all lines and format them so we can have them
    # limitted to 100 characters max.
    done = False

    for line in lines:
        if len(line) > lineLength:
            while False == done:
                done = len(line) < lineLength
                if True is done:
                    newLines.append(line[:lineLength].strip())
                else:
                    loc = line[:lineLength].rfind(" ")

                    if loc == -1:
                        done = True
                    else:
                        newLines.append(line[:loc].strip())
                        line = line[loc:].strip()
        else:
            newLines.append(line)

    return newLines

def processLine(line):
    '''
        processLine(line)

        Description: processes a single row of information to create a map of the type for each entry

        Parameters:
            o - line -> A signle row of information

        Returns:
            Returns a single row converted into a single map entry representing the row fields
    '''
    fields = None
    stripItems = []
    fields = {}

    # Clean up each entry for leading and trailing spaces
    for item in line:
        stripItems.append(str(item).strip())

    # Create a map that represents the row
    fields["type"] = stripItems[0]
    fields["alias"] = stripItems[1]
    fields["name"] = stripItems[2]
    fields["val"] = stripItems[3]
    fields["size"] = stripItems[4]
    fields["desc"] = stripItems[5]

    return fields


def processFile(file):
    '''
        processFile(file)

        Description: Returns a list of file data nodes(map), each node is a map with
                     the following keys:
                     o - alias is register's alias name
                     o - reg is the register name
                     o - value is the address of each register
                     0 - desc is the description of each register

        Parameters:
            o - file -> The string representation name of the csv file to open and load.
                        File names are considered fully resolved paths.
    '''

    inputFileLines = fileToStringArray(file)
    model = []

    for line in inputFileLines:
        node =  processLine(line)

        if node == None:
            continue
        else: 
            model.append(node)

    return model

def printDataModel(model):

    '''
        printDataModel(model)

        Description: Prints on the console a data model of the register map in a non languages specific format.

        Parameters:
            o - model -> The register model in a list or register maps.
    '''
    for node in model:

        if node["type"] == "R":
            print("Register Alias: {},\n"
                  "Register Name: {},\n"
                  "Register Value: {},\n"
                  "Register Μask: {},\n"
                  "Register Description: {}\n".
                  format(node["alias"], node["name"], node["val"], node["size"], node["desc"]))

        if node["type"] == "C" :
            print("Constant Alias: {},\n"
                  "Constant Name: {},\n"
                  "Constant Value: {},\n"
                  "Constant Mask {},\n"
                  "Constant Description: {}\n".
                  format(node["alias"], node["name"], node["val"], node["size"], node["desc"]))

        if node["type"] == "F" :
            print("Bitfield Alias: {},\n"
                  "Bitfield Name: {},\n"
                  "Bitfield Position: {},\n"
                  "Bitfield Size: {},\n"
                  "Bitfield Description: {}\n".
                  format(node["alias"], node["name"], node["val"], node["size"], node["desc"]))

    return model

def printDataModelInCRegister(node):

        if( len(node["desc"]) > 0 ):
            print("/**\n *\n * " + node["desc"] + "\n * \n */")

        if( len(node["alias"]) > 0 ):
            print("#define {:30} {:20} /* Original Register Name: {} */".format(node["alias"], node["val"], node["name"]))
            if( len(node["size"]) > 0 ):
                print("#define {:30} {:20}\n".format(node["alias"]+"_MASK", node["size"]))
        else:
            print("#define {:30} {:20}".format(node["name"], node["val"]))
            if( len(node["size"]) > 0 ):
                print("#define {:30} {:20}\n".format(node["name"]+"_MASK", node["size"]))


def printDataModelInCField(node):
    '''
        printDataModelInCField(node)

        Description: Prints out the node details in an ANSI C Format

        Parameters:
            o - node -> a signle node consisting of the info for one node.

        Returns:
            N/A 

    '''

    mask = 0x00000000
    size = int(node["size"], 16)
    offset = int(node["val"])

    mask = (2**size) - 1

    descLines = getDescriptionLines(node["desc"])

    print("/**")
    for line in descLines:
        print(f" * {line}")
    print(f" * Mask: 0x{(mask << offset):08X}")
    print(" */")
    print(f"#define {node['alias']+ '_OFFSET':30} {str(offset):20}")
    print(f"#define {node['alias']+ '_MASK':30} (0x{mask:08X} << {node['alias']}_BIT_OFFSET)\n")


def printDataModelInC(model):
    '''
        printDataModelInC(model)

        Description: Prints out the model details in an ANSI C Format

        Parameters:
            o - model -> a list of model nodes

        Returns:
            The raw model, in case this method's return needs to go through
            more processing.

    '''
    for node in model:

        if node["type"] == "R"  or node["type"] == "C":
            printDataModelInCRegister(node)

        if node["type"] == "F":
            printDataModelInCField(node)


    return model

def printDataModelInAsm(model):
    '''
        printDataModelInAsm(model)

        Description: Prints out the model details in an GNU ASM Format

        Parameters:
            o - model -> a list of model nodes

        Returns:
            The raw model, in case this method's return needs to go through
            more processing.

    '''
    for node in model:
        # R -> Register
        # C -> Constant
        # F -> Field

        # Create a map that represents the row
        # fields["type"] = stripItems[0]
        # fields["alias"] = stripItems[1]
        # fields["name"] = stripItems[2]
        # fields["val"] = stripItems[3]
        # fields["size"] = stripItems[4]
        # fields["desc"] = stripItems[5]

        if node["type"] == "R"  or node["type"] == "C":
            newComment = f"\n##\n## Register\n## {node['name']:.<30}: {node['desc']}\n##"
            newEQU = f".equ {node['alias']}, ({node['val']})"
            print(newComment)
            print(newEQU)

        if node["type"] == "F":
            newComment = f"\n##\n## Field\n## {node['name']:.<30}: {node['desc']}\n##"
            bitFieldNumber = (2**int(node['size'],16)) - 1
            bitFieldHexStr = f"0x{bitFieldNumber:08X}"
            newEQU = f".equ {node['alias']}, ({bitFieldHexStr} << {node['val']})"
            print(newComment)
            print(newEQU)
            continue


    return model



def fileType(code):
    '''
        fileType(fileName)

        Description: Returns the file name extension in a string

        Parameters:
            o - fileName -> A string representing a file name with its extension.
                            the format expected is: *.ext, where * is any valid
                            filename and ext is a any file name extension
                            e.g. h, s, asm...etc
    '''
    if None is code:
        return None

    if len(str(code)) > 1:
        return 'u' #For Unknown

    return code




def getFileTypeHandler(fileType):
    '''
        getFileTypeHandler(fileType)

        Description: Returns the parsing handler for the file type specified in the parameter

        Parameters:
            o - fileType -> A string representing a file name extension. Current hanlders
                            support finame types such as ASM (.s) and C Header (.h) all other
                            extensions will return an error

        Returns:
            On successful completion this method returns the function hanlder for the specific
            file type, otherwise it returns None

        Note:
            All handlers must be defined prior to this method and should be added in the
            local map 'fileTypeHanlders'
    '''
    fileTypeHanlders = {
        "c" : printDataModelInC,
        "s" : printDataModelInAsm,
        "u" : printDataModel,
        }

    hanlder = None

    try:
        hanlder = fileTypeHanlders[fileType]
    except KeyError as err:
        errorTxt = f"Check your command line invocation --output = '{fileType}' is not a supported output format"
        print (errorTxt)

    return hanlder


def main():

    parser = argparse.ArgumentParser("Generates either a C Header with defines or a asm file with consts\n")

    # Positional argument for the input csv file
    parser.add_argument(
        'csvFileName',
        help = 'The name of the CSV input file\n',
        default = None,
    )

    # Optional argument to determine which type of file to generate,
    # if none presented then we'll just simply print out the model.
    parser.add_argument(
        '--output',
        help='[c|s] where \'c\' is specified a ANSI C header file format will be printed, whereas \'s\' an Assembly file format will be printed\n',
        default = None,
    )

    args = parser.parse_args()

    if None == args.csvFileName:
        parser.print_usage()
        return sys.exit(-1)

    dataModel = processFile(args.csvFileName)

    if args.output != None :
        extension = fileType (args.output)
        handler = getFileTypeHandler(extension)
        if None != handler:
            handler(dataModel)


def fileToStringArray(file):
    '''
        fileToStringArray(file)

        Description: Reads in the spreadsheet to get all the register data

        Parameters :
            o - file -> A string to the full path and file name of the xlsx file that will be processed

        Returns: If successful it returns the string array representing each row in a list format, if not it returns None.
    '''
    if None == file:
        return None
    
    if False == os.path.exists(file):
        return None

    # Create an emtpy list so we can populate it
    rawList = []
    lines = []

    # Read the content of the entire file a line at the time
    # store each line as a single entry in the lines list.
    with open(file, encoding='utf-8') as f:
        lines = f.readlines()
    
    # Bail out gracefully if the line returned are None
    if lines is None:
        print(f"Failed to Read the contents of the file {file}")

    # Split each line into a list of strings deleanated by a comma
    for line in lines :
        # Split the line along the comma delineator
        basicSplit = line.split(',')
        # There shouldn't be any commas in any of the first 5 elements.
        elements = basicSplit[:5]
        # Create a new description field for remaining elements
        desc = ""

        # If there are more than 6 fields means the description 
        # contained comma(s), concatenate them. 
        if len(basicSplit) > 6 :        
            for e in basicSplit[5:]: 
                desc += e
        else:
            desc = basicSplit[5]

        # Add the concatenated description back into 
        # the processed elements 
        elements.append(desc)

        # Now add the properly split string into the raw list.
        rawList.append(elements)

    return(rawList)

if __name__ == "__main__" :
    main()
