# on ec2 termination

This lambda **creates a snapshot** of the root ebs volume on termination
and a **custom ami** from which you can boot.

```
$ make
```

will create a terraform module within the `./build` folder.
