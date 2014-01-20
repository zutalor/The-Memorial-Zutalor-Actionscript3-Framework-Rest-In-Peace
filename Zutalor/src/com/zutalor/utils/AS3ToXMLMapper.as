package com.zutalor.utils 
{
    import flash.utils.describeType;

    public class AS3ToXMLMapper
    {

        public function AS3ToXMLMapper()
        {
        }

        public static function generateXML(objectToMap:Object, basePropertyName:String="root"):String
        {
            var describeXML:XML = describeType(objectToMap);

            var xmlOutput:String = "<"+basePropertyName+" name=\""+describeXML.@name+"\" base=\""+describeXML.@base+"\">\n";

            if(describeXML.@isDynamic=="true")
            {
                for(var property:String in objectToMap)
                {
                    xmlOutput += "<"+property+">";
                    xmlOutput += objectToMap[property];
                    xmlOutput += "</"+property+">";
                }
            }
            else if(objectToMap is XML)
            {
                xmlOutput+=(objectToMap as XML).toString();
            }
            else if(objectToMap is XMLList)
            {
                xmlOutput+=(objectToMap as XMLList).toString();
            }
            else
            {
                for each(var accessor:XML in describeXML..accessor)
                {
                    xmlOutput+="\t"+exportProperty(objectToMap, accessor,true);
                }
                for each(var variable:XML in describeXML..variable)
                {
                    xmlOutput+="\t"+exportProperty(objectToMap, variable, false);
                }
            }

            xmlOutput += "</"+basePropertyName+">\n";
            trace(xmlOutput);
            return xmlOutput;
        }

        private static function exportProperty(objectToMap:Object, xmlObj:XML, isAccessor:Boolean):String
        {
            var xmlOutput:String="";
            var propName:String = xmlObj.@name.toString();
            var objectValue:Object = objectToMap[propName];
            if(!objectValue)
            {
                xmlOutput += "<"+propName+">";
                xmlOutput += "</"+propName+">";
                return xmlOutput;
            }

            if(isAccessor && xmlObj.@access != "readwrite")
            {
                return "";
            }
            if(objectValue is Array)
            {
                return exportArray(objectValue as Array, xmlObj.@name);
            }
            else if(objectValue is int || objectValue is Number || objectValue is String || objectValue is uint || objectValue is Boolean)
            {
                xmlOutput += "<"+propName+" type=\""+xmlObj.@type+"\">";

                xmlOutput += objectValue;
                xmlOutput += "</"+propName+">"; 
            }
            else
            {
                return generateXML(objectValue, propName);
            }
            return xmlOutput;
        }

        private static function exportArray(array:Array, arrayName:String):String
        {
            var xmlOutput:String = "<"+arrayName+">\n";

            for each(var element:Object in array)
            {
                xmlOutput+="\t"+generateXML(element,"arrayElement");
            }

            xmlOutput += "</"+arrayName+">\n";
            return xmlOutput;
        }
    }
}