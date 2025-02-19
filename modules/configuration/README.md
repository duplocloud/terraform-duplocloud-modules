# Duplo Configuration Module 

Builds a configuration a number of ways for an application. 

## Classes  

Each class is a different way to build a configuration. The following sections details the different classes. To set the class, use the `class` variable as an input. The default is `configmap`. 

Options for `class` are:  
- `configmap`  
- `secret`
- `aws-secret`
- `aws-ssm`

## CSI Support  

If your cluster has the aws csi driver for secrets enabled, then this can be true. When true you can use `aws-secret` or `aws-ssm` as the class.
