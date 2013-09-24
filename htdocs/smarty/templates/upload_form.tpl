{strip}
<form method="post" action="{$scriptname}?action=templog&subaction=upload_results" enctype="multipart/form-data">
	Upload temperature logging file: <input type="file" name="templog" />
	<input type="submit" name="submit" value="Upload" />
	{*
	<input type="hidden" name="action" value="templog" />
	<input type="hidden" name="subaction" value="upload_results" />
	*}
</form>
<br />
{/strip}
