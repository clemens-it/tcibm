{strip}
{include file='message.tpl'}
{* shows content of variable data in a table *}
{$count_data} records found.
<table style="border-collapse:collapse;" >
	{assign var="id" value=-1}
	{foreach name="row" from=$data item=v}
		{* first row *}
		{if $smarty.foreach.row.first}
			<tr>
				{* <th></th> *}
				{foreach from=$v item=w key=k}
					<th style="padding:5px 3px 5px 3px;">{$k|capitalize:true}</th>
				{/foreach}
			</tr>
		{/if}
		<tr style="background-color:{cycle values="#eeeeee,#d0d0d0"};">
			{foreach name="cols" from=$v item=w}
				<td style="padding:5px 7px 5px 5px; border-bottom:1px solid lightgray;">{$w}</td>
			{/foreach}
		</tr>
	{/foreach}
</table>
{/strip}
