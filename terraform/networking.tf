# ————————— VPC Config ————————— #
resource "aws_vpc" "main" {
    cidr_block              = var.vpc_cidr
    enable_dns_support      = true
    enable_dns_hostnames    = true
    tags = { Name = "ShopCloud-VPC" }
}
# ————————— AZs ————————— #
# Fetch avaiable AZs in the region.
# Referenced like arrays:
#   data.aws_availability_zones.avaiable.names[0] for the first AZ
#
# Note: An Amazon EKS deployment requires a VPC with sufficient IP
# addresses and at least two subnets located in different Availability
# Zones (AZs) to ensure high availability and proper communication
# between the AWS-managed control plane and your worker nodes.

data "aws_availability_zones" "available" {
    state = "available"
}
# ————————— Internet Gateway ————————— #
# Required for public ingress via load balancer.
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "ShopCloud-IGW" }
}
# ————————— Elastic IP for NAT Gateway ————————— #
resource "aws_eip" "nat" {
    domain = "vpc"
    tags = { Name = "ShopCloud-NAT-EIP" }
}
# ————————— NAT Gateway (in public subnet) —————————
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_1.id
    tags = { Name = "ShopCloud-NAT-GW" }
    depends_on = [aws_internet_gateway.main]
}
# ————————— Public Subnet 1 ————————— #
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_1_cidr
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    tags = { Name = "ShopCloud-Public-Subnet-1" }
}
# ————————— Public Subnet 2 ————————— #
resource "aws_subnet" "public_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_2_cidr
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = true
    tags = { Name = "ShopCloud-Public-Subnet-2" }
}
# ————————— Private Subnet 1 ————————— #
resource "aws_subnet" "private_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_3_cidr
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false
    tags = { Name = "ShopCloud-Private-Subnet-1" }
}
# ————————— Private Subnet 2 ————————— #
resource "aws_subnet" "private_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_4_cidr
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = false
    tags = { Name = "ShopCloud-Private-Subnet-2" }
}
# ————————— DB Subnet 1 ————————— #
resource "aws_subnet" "db_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_5_cidr
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false
    tags = { Name = "ShopCloud-DB-Subnet-1" }
}
# ————————— DB Subnet 2 ————————— #
resource "aws_subnet" "db_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_6_cidr
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = false
    tags = { Name = "ShopCloud-DB-Subnet-2" }
}
# ————————— Public Route Table ————————— #
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = { Name = "ShopCloud-Public-RT" }
}
# —————————  Associate public subnets with public route table ————————— #
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.public.id
}
# ————————— Private Route Table ————————— #
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }
    tags = { Name = "ShopCloud-Private-RT" }
}
# —————————  Associate private subnets with private route table ————————— #
resource "aws_route_table_association" "private_1" {
    subnet_id = aws_subnet.private_1.id
    route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_2" {
    subnet_id = aws_subnet.private_2.id
    route_table_id = aws_route_table.private.id
}

# ————————— DB/Cache Isolated Route Table ————————— #
resource "aws_route_table" "isolated" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "ShopCloud-Isolated-RT" }
}

resource "aws_route_table_association" "db_1" {
    subnet_id = aws_subnet.db_1.id
    route_table_id = aws_route_table.isolated.id
}

resource "aws_route_table_association" "db_2" {
    subnet_id = aws_subnet.db_2.id
    route_table_id = aws_route_table.isolated.id
}
