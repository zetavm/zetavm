# TODO: use env var for pass, don't put directly in command
# unset when done

curl -X POST -F 'user=mcuser' -F 'pass=foo' -F 'pkg_name=libfoo' -F 'file_field=@path_to_file' -k https://localhost:7000/upload_pkg
