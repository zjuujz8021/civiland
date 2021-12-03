from brownie import *
from brownie.network import account

def main():
    acc = accounts.add("0x29f4c2e330959c24f053d927344215acafdea943d62859674ea4958e3eb894d8")
    print("current address is:", acc.address)

    test = Civiland.deploy("Civiland", "CIV", {
        'from': accounts[0]
    })
    # print(test.f(3, 5))