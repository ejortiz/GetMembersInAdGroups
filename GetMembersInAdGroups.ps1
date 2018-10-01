# Replace the text within the filter and add wilcards as necessary
$groups=Get-ADGroup -Filter {name -like "*TEST*" -or name -like "*TEST2*" } `
		-Properties Description, Name, SamAccountName, DistinguishedName, SID, ObjectGUID | Select Name, SamAccountName, DistinguishedName, SID, ObjectGUID

# default script output to desktop, named "adgroupMembers.csv"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$csvFileName = $desktopPath + "\adgroupMembers.csv"

$arrOfGroupMemberArrs=New-Object System.Collections.ArrayList

foreach  ($element in $groups)
{
	$groupMembers=@()
	$item=$null
	try
	{
		$item=Get-ADGroupMember -Identity $element.SID -recursive| Select Name, SamAccountName
	}
	catch
	{
		$item=Get-ADGroupMember -Identity $element.ObjectGUID | Get-ADUser -Properties Name, SamAccountName | Select Name, SamAccountName
	}	
	$groupMembers += @($item)
	$arrOfGroupMemberArrs.add($groupMembers)
}

#Create Table object
$table = New-Object system.Data.DataTable "table"
$col1 =  New-Object system.Data.DataColumn User,([string])
$col2 =  New-Object system.Data.DataColumn SamAccountName,([string])
$col3 =  New-Object system.Data.DataColumn ADGroup,([string])
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)

#TODO: split the code in the foreach loops into its own function
# loop through all the groups if they are an array
if($groups.GetType().IsArray)
{
	for($i=0; $i -lt $groups.Length; $i++)
	{
		$groupName = $groups[$i].Name
		foreach($element in $arrOfGroupMemberArrs[$i])
		{
			$row = $table.NewRow()
			$row.User = $element.Name
			$row.SamAccountName = $element.SamAccountName
			$row.ADGroup = $groupName
			$table.Rows.Add($row)
		}
	}
}
# else, "groups" is only a group
else
{
		$groupName = $groups.Name
		foreach($element in $arrOfGroupMemberArrs[0])
		{
			$row = $table.NewRow()
			$row.User = $element.Name
			$row.SamAccountName = $element.SamAccountName
			$row.ADGroup = $groupName
			$table.Rows.Add($row)
		}

}

# $table | format-table -AutoSize # Output table to screen
$tabCsv = $table | export-csv $csvFileName -noType


