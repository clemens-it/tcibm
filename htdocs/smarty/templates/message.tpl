{strip}
{if $msg}
<div>
	{$msg|nl2br}
</div>
{/if}

{if $errormsg}
<div class="errorbox">
	{$errormsg|nl2br}
</div>
{/if}
{/strip}
