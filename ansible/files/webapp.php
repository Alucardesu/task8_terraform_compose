<!DOCTYPE html>
<html>
<body>

<?php
echo gethostname();
?>

<form action="/insert.php">
  <label for="iname">Item Name: </label>
  <input type="text" id="iname" name="iname" value="" maxlength="20">
  <label for="number">Quantity: </label>
  <input type="number" id="quantity" name="quantity" min="1" max="5">
  <input type="submit" value="Submit">
</form> 
<br>
<form method="get" action="/select.php">
  <button type="submit">Select</button>
</form>

</body>
</html>