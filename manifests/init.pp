 class visualstudio ($versions)
 {
  if member($versions, '2010') {
    include visualstudio::vs2010
  }
   if member($versions, '2012') {
    include visualstudio::vs2012
  }
  if member($versions, '2013') {
    include visualstudio::vs2013
  }
  if member($versions, '2015') {
    include visualstudio::vs2015
  }
}
