import boto3


RT_TAG = "cptc8-def_route_table"
INST_TAG = "cptc8-wireguard_vpn"


def main():
    client = boto3.client("ec2", region_name="us-east-1")

    rt_res = client.describe_route_tables(
        Filters=[
            {
                "Name": "tag:Name",
                "Values": [
                    RT_TAG,
                ],
            },
        ],
    )

    if len(rt_res["RouteTables"]):
        rt_id = rt_res["RouteTables"][0]["RouteTableId"]
    else:
        print(f"No Route Table with tag '{RT_TAG}'")
        exit()

    inst_res = client.describe_instances(
        Filters=[
            {
                "Name": "tag:Name",
                "Values": [
                    INST_TAG,
                ],
            },
        ],
    )

    if len(inst_res["Reservations"]):
        for inst in inst_res["Reservations"][0]["Instances"]:
            if inst["State"]["Code"] == 16:
                eni_id = inst_res["Reservations"][0]["Instances"][0][
                    "NetworkInterfaces"
                ][0]["NetworkInterfaceId"]
                print("success")
                break
    else:
        print(f"No instance with tag '{INST_TAG}'")
        exit()

    if not eni_id:
        print(f"No running instance with tag '{INST_TAG}'")

    client.replace_route(
        DestinationCidrBlock="10.0.0.0/16",
        NetworkInterfaceId=eni_id,
        RouteTableId=rt_id,
    )


if __name__ == "__main__":
    main()
