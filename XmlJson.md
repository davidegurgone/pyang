# Introduction #

Back in 2003, when NETCONF was conceived, the choice of XML as the format for message contents seemed more or less automatic. These days, JSON is much more popular as a vehicle for encoding hierarchically structured data. Several applications in the area of network device configuration already express data in JSON.

IETF Internet-Draft [draft-ietf-netmod-yang-json](http://tools.ietf.org/html/draft-ietf-netmod-yang-json) enables JSON as the alternative encoding format for data modelled with YANG. It does so indirectly because YANG uses some concepts, such as XPath, that are only defined for XML. The Internet-Draft establishes equivalence (one-to-one mapping) between JSON and the subset of XML that can be modelled by YANG. Many statements about XML-encoded data, for example about validity, then apply to the equivalent JSON-encoded data, and vice versa.

Two pyang plugins, `jsonxsl` and `jtox`, implement both directions of the mapping. Their results are generally better than those obtained from a generic XML-JSON convertor because the mapping actively uses the YANG data model. This means, for example, that
  * numeric leaf nodes are mapped to JSON numbers, or
  * lists or leaf-lists having only a single entry are still mapped to JSON arrays.

# Translating XML into JSON #

The `jsonxsl` plugin takes a YANG data model (see [Tutorial#YANG\_Data\_Model](Tutorial#YANG_Data_Model.md)) and generates an XSLT1 stylesheet from it. This stylesheet then can be used for translating any _valid_ XML instance of the data model into JSON.

For our example YANG module, [turing-machine.yang](https://code.google.com/p/pyang/source/browse/trunk/doc/tutorial/examples/turing-machine.yang), the XSLT stylesheet is generated with this command:
```
$ pyang -f jsonxsl -o tm-json.xsl turing-machine.yang
```

We can then use the stylesheet, `tm-json.xsl`, with any XSLT1 processor and translate any valid XML instance document of the following types:
  * Configuration data, or configuration together with state data, encapsulated in either `<nc:config>` or `<nc:data>` element, where the `nc` prefix stands for the standard NETCONF namespace URI `urn:ietf:params:xml:ns:netconf:base:1.0`.
  * RPC request for a method defined by the Turing Machine data model, encapsulated in `<nc:rpc>`. It could be a RPC reply, too, but our data model defines no specific replies.
  * Notification, encapsulated in `<en:notification>`, where the `en` prefix stands for the standard NETCONF namespace URI `urn:ietf:params:xml:ns:netconf:notification:1.0`.

For example, we can translate an instance configuration into neatly formatted JSON text:
```
$ xsltproc -o turing-machine-config.json tm-json.xsl turing-machine-config.xml
$ cat turing-machine-config.json 
{
  "turing-machine:turing-machine": {
    "transition-function": {
      "delta": [
        {
          "label": "left summand",
          "input": {
            "state": 0,
            "symbol": "1"
          }
        },
        {
          "label": "separator",
          "input": {
            "state": 0,
            "symbol": "0"
          },
          "output": {
            "state": 1,
            "symbol": "1"
          }
        },
        {
          "label": "right summand",
          "input": {
            "state": 1,
            "symbol": "1"
          }
        },
        {
          "label": "right end",
          "input": {
            "state": 1,
            "symbol": ""
          },
          "output": {
            "state": 2,
            "head-move": "left"
          }
        },
        {
          "label": "write separator",
          "input": {
            "state": 2,
            "symbol": "1"
          },
          "output": {
            "state": 3,
            "symbol": "0",
            "head-move": "left"
          }
        },
        {
          "label": "go home",
          "input": {
            "state": 3,
            "symbol": "1"
          },
          "output": {
            "head-move": "left"
          }
        },
        {
          "label": "final step",
          "input": {
            "state": 3,
            "symbol": ""
          },
          "output": {
            "state": 4
          }
        }
      ]
    }
  }
}
```

Note that due to schema-awareness the translation takes into account the difference between the number 0 and the string "0" even though they look the same as in XML.

Sometimes the extra whitespace of a pretty-printed JSON is not desirable, for example, if the JSON text is intended to be sent over network. To achieve this, the stylesheet can be passed the `compact` parameter with a non-zero value:
```
$ xsltproc -o stripped.json --stringparam compact 1 tm-json.xsl turing-machine-config.xml
```

# Translating JSON into XML #

The translation in the opposite direction is complicated by the fact that there is no such thing as XSLT for JSON. Therefore, one option would be to take both the data model and a JSON instance and return an XML instance.

The `jtox` plugin opted for a different approach: it takes only the data model and produces a JSON-encoded driver file that contains all the information necessary for the JSON-to-XML translation. A relatively simple Python script, [json2xml](https://code.google.com/p/pyang/source/browse/trunk/bin/json2xml) than uses this driver file for translating any valid JSON instance to XML.

For example, this command produces the driver file for our Turing Machine model:
```
$ pyang -f jtox -o turing-machine.jtox turing-machine.yang
```

Now, we can translate a JSON instance into XML like this:
```
$ json2xml -t config -o tm-config.xml turing-machine.jtox turing-machine-config.json
```

The `-t` option specifies the `target`, which can be either `config` or `data`. It determines the XML element that encapsulates the data, i.e. either
```
<nc:config xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"/> 
```

or
```
<nc:data xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"/>
```
respectively. Consult [json2xml(1)](http://www.yang-central.org/twiki/pub/Main/YangTools/json2xml.1.html) manual page for further details.

The result is a valid XML instance:
```
$ yang2dsdl -s -j -b turing-machine -t config -v tm-config.xml
== Using pre-generated schemas

== Validating grammar and datatypes ...
tm-config.xml validates.

== Adding default values... done.

== Validating semantic constraints ...
No errors found.
```



<a href='Hidden comment: 
Local Variables:
mode: fundamental
mode: visual-line
End:
'></a>