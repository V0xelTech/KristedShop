return {
  ["Shop-Name"]="", --Your shop name
  ["Description"]="", --Something greething
  ["Owner"]="", --The name of the shop owner
  ["Wallet-Key"]="", --Your wallet privateKey
  ["Wallet-id"]="", --Your wallet address
  ["Redstone_Output"]="top", --The redstone output
  ["Self-Id"]="turtle_", --The turtle id of your network
  ["Discord-Webhook"]=false, --Enable if you want discord webhook
  ["Discord-Webhook-URL"]="", --Your discord webhook url here
  ["Theme"]={
    ["Background-Color"]=0x100, --The shop's background color
    ["Text-Color"]=0x800 --The shop's text color
  },
  ["Items"]={ --The items to sell
    {
      ["Name"]="Example", --Some friendly name
      ["Id"]="minecraft:wheat", --The name of the item
      ["Price"]=1, --The price / item
      ["Alias"]="empl"
    },
  },
  ["Enable-Automatic-Update"]=true, --Enable automatic updates
  ["Version"]="0.2.1" --the kristed version (if your shop buggy then just edit this and the shop will automatically reinstall itself)
}
