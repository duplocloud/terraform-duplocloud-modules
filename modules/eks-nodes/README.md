# EKS HA Nodes  

Creates duplocloud EKS hosts for a tenant. This creates an HA setup on at least two zones. The min/max/count is actually multiplied by the amount of zones. So if you have 3 zones and you set min=1, max=3, count=2, you will get 6 hosts. 