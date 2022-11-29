# on ec2 termination

This lambda **creates a snapshot** of the root ebs volume on termination
and a **custom ami** from which you can boot.

```
$ make
```

will create a terraform module within the `./build` folder.

# Requirements

You need `Python 3.9.x` installed.
You can set up your `venv` with


# Dev requirements

```
$ make requirements_dev
```

to have access to the **chalice toolchain**.
