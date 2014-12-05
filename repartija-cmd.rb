
def Preparar_listas()
    $aportes = [43,10,27,14,0,0,106,0,0,0]
    puts $aportes.to_s
    puts "Total: " 
    puts $total = $aportes.reduce(:+)
    puts "Pago individual: " 
    puts $pago_individual = $total/$aportes.count
    $saldos = $aportes.map {|e| $pago_individual - e }
end

def Separar_lista()
    $acreedores, $deudores = $saldos.partition { |e| e < 0 }
    puts "acreedores: "
    puts $acreedores.to_s
    puts "deudores: "
    puts $deudores.to_s 
end

def Calcular()
    $acreedores.each do |a|
        $acumulado = 0
        puts
        puts "Para acreedor: " + a.to_s
        $deudores.map! do |d|
            if(d > 0)
                puts
                puts "el deudor: " + ( $deudores.index( d ) + 1 ).to_s
                $acumulado += d
                $resto = $acumulado + a
                if( $resto > 0 && $resto < $pago_individual)
                    puts "Paga: " + ($pago_individual - $resto).to_s
                    d = $resto
                elsif (d < $pago_individual)
                    puts "ppaga: " + d.to_s
                    d = 0
                elsif ( $resto > $pago_individual)
                    puts "No paga"
                    d = $pago_individual
                else
                    puts "paga: " + $pago_individual.to_s
                    d = 0
                end
                #puts $resto
            else
                d = 0
            end
            #puts $resto
        end
        #$deudores.delete_if { |e| e < 0}
        puts $deudores.to_s
    end 
end

Preparar_listas()
Separar_lista()
Calcular()
