import os
import platform
import sys


def repos_finder(absolute_path: str, repo_name: str):
    """
    Given the name of the directory that is above the current working directory,
    it returns its absolute path

    :param absolute_path: absolute path to working directory
    :param repo_name: name of the directory to find
    :return: the absolute path of the given directory
    """

    # Splitting path and jumping first empty element
    split_path = absolute_path.split('/')[1:]

    # Checking if the OS is Windows to change the path
    if platform.system() == 'Windows':
        split_path[0] = 'C:'
        split_path.insert(1, 'Users')

    found_repo = ''
    # Loop to search for the wanted directory in every directory above the working directory
    for directory in split_path:

        # Skip 'c/' and 'C:/' directories
        if directory in ('c', 'C:'):
            continue

        # If the directory is the one we are looking for
        if directory == repo_name:
            # Get its index
            repo_index = split_path.index(repo_name)
            # Re-build the path to the wanted directory
            path_to_repo = '/'.join(split_path[:repo_index + 1])
            # Updated the found repo to return
            found_repo += path_to_repo

            return found_repo

        else:
            # Get index of directory
            dir_index = split_path.index(directory)
            # Re-build path to directory to look for directories below it
            path_to_dir = '/'.join(split_path[:dir_index + 1])
            # Loop to search the wanted directory in these sub-directories
            for sub_dir in os.listdir(path_to_dir):
                # If the directory is the one we are looking for, the same as above
                if sub_dir == repo_name:
                    path_to_repo = '/'.join(split_path[:dir_index + 1]) + f'/{sub_dir}'
                    found_repo += path_to_repo

                    return found_repo


if __name__ == '__main__':
    # Getting arguments for the function from 'vars.sh'
    abs_path1 = sys.argv[1]
    abs_path2 = sys.argv[2]
    # Return result to 'vars.sh'
    print(repos_finder(abs_path1, abs_path2))
    sys.exit(0)
