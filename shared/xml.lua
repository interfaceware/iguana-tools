-- xml module
-- http://help.interfaceware.com/code/details/xml-lua
-- Helpful extensions to core xml library in Iguana.

-- Prior to the nodeText method we used to have a text() helper method
-- This is gone now.

-- set or create+set a text element
function node.setText(X, T)
    for i=1,#X do
      if X[i]:nodeType() == 'text' then
         X[i]:setInner(T)
      end
   end
	return X:append(xml.TEXT, T)
end

-- set or create+set an XML attribute
function node.setAttr(N, K, V)
   if N:nodeType() ~= 'element' then
      error('Must be an element')
   end
   if not N[K] or N[K]:nodeType() ~= 'attribute' then
      N:append(xml.ATTRIBUTE, K)
   end
   N[K] = V
   return N
end

-- find an XML element by name
function xml.findElement(X, Name)
   if X:nodeName() == Name then
      return X
   end
   for i = 1, #X do
      local Y = xml.findElement(X[i], Name)
      if Y then return Y end
   end
   return nil
end

-- append an XML element
function node.addElement(X, Name)
   return X:append(xml.ELEMENT, Name)
end